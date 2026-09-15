#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly ISSUES_FILE="${REPO_ROOT}/config/github/issues.tsv"
readonly TEMPLATE_FILE="${REPO_ROOT}/config/github/templates/issue-body.md"

MODE="dry-run"

usage() {
    cat <<'USAGE'
Usage:
  create-issues.sh
  create-issues.sh --dry-run
  create-issues.sh --apply

Modes:
  --dry-run   Preview issue creation without modifying GitHub. Default.
  --apply     Create missing GitHub issues.

Safety:
  Dry-run mode is the default.
  Existing issues are detected using the stable work-item key.
USAGE
}

render_issue_body() {
    local key="$1"
    local title="$2"
    local milestone="$3"
    local priority="$4"
    local domain="$5"
    local work_type="$6"
    local phase="$7"
    local effort="$8"
    local risk="$9"
    local environment="${10}"

    sed \
        -e "s|{{KEY}}|${key}|g" \
        -e "s|{{TITLE}}|${title}|g" \
        -e "s|{{MILESTONE}}|${milestone}|g" \
        -e "s|{{PRIORITY}}|${priority}|g" \
        -e "s|{{DOMAIN}}|${domain}|g" \
        -e "s|{{WORK_TYPE}}|${work_type}|g" \
        -e "s|{{PHASE}}|${phase}|g" \
        -e "s|{{EFFORT}}|${effort}|g" \
        -e "s|{{RISK}}|${risk}|g" \
        -e "s|{{ENVIRONMENT}}|${environment}|g" \
        "${TEMPLATE_FILE}"
}

issue_exists() {
    local key="$1"

    gh api \
        --paginate \
        "repos/${GITHUB_REPOSITORY}/issues?state=all&per_page=100" \
        --jq '.[] | select(.pull_request == null) | .body // ""' |
        grep -Fq "Project work item: \`${key}\`"
}

create_issue() {
    local title="$1"
    local milestone="$2"
    local labels="$3"
    local body_file="$4"

    local milestone_number

    milestone_number="$(
        gh api \
            --paginate \
            "repos/${GITHUB_REPOSITORY}/milestones?state=all&per_page=100" \
            --jq ".[] | select(.title == \"${milestone}\") | .number" |
            head -n 1
    )"

    [[ -n "${milestone_number}" ]] ||
        fail "Unable to resolve milestone: ${milestone}"

    local -a command=(
        gh issue create
        --repo "${GITHUB_REPOSITORY}"
        --title "${title}"
        --body-file "${body_file}"
        --milestone "${milestone}"
    )

    local label

    IFS=',' read -r -a issue_labels <<< "${labels}"

    for label in "${issue_labels[@]}"; do
        command+=(--label "${label}")
    done

    "${command[@]}"
}

main() {
    local argument

    for argument in "$@"; do
        case "${argument}" in
            --dry-run)
                MODE="dry-run"
                ;;
            --apply)
                MODE="apply"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                fail "Unknown argument: ${argument}"
                ;;
        esac
    done

    initialize_github_automation

    [[ -f "${ISSUES_FILE}" ]] ||
        fail "Issue configuration not found: ${ISSUES_FILE}"

    [[ -f "${TEMPLATE_FILE}" ]] ||
        fail "Issue template not found: ${TEMPLATE_FILE}"

    log "Mode: ${MODE}"

    local planned=0
    local existing=0
    local created=0

    while IFS=$'\t' read -r \
        key \
        title \
        milestone \
        priority \
        domain \
        work_type \
        phase \
        effort \
        risk \
        environment \
        labels; do

        [[ "${key}" != "key" ]] || continue
        [[ -n "${key}" ]] || continue

        ((planned += 1))

        printf '\n'
        printf '%s\n' '------------------------------------------------------------'
        printf 'Work Item:   %s\n' "${key}"
        printf 'Title:       %s\n' "${title}"
        printf 'Milestone:   %s\n' "${milestone}"
        printf 'Priority:    %s\n' "${priority}"
        printf 'Domain:      %s\n' "${domain}"
        printf 'Work Type:   %s\n' "${work_type}"
        printf 'Phase:       %s\n' "${phase}"
        printf 'Effort:      %s\n' "${effort}"
        printf 'Risk:        %s\n' "${risk}"
        printf 'Environment: %s\n' "${environment}"
        printf 'Labels:      %s\n' "${labels}"

        if issue_exists "${key}"; then
            printf 'Action:      SKIP — issue already exists\n'
            ((existing += 1))
            continue
        fi

        if [[ "${MODE}" == "dry-run" ]]; then
            printf 'Action:      WOULD CREATE\n'
            continue
        fi

        local body_file
        body_file="$(mktemp)"

        render_issue_body \
            "${key}" \
            "${title}" \
            "${milestone}" \
            "${priority}" \
            "${domain}" \
            "${work_type}" \
            "${phase}" \
            "${effort}" \
            "${risk}" \
            "${environment}" > "${body_file}"

        create_issue \
            "${title}" \
            "${milestone}" \
            "${labels}" \
            "${body_file}"

        rm -f "${body_file}"

        ((created += 1))
    done < "${ISSUES_FILE}"

    printf '\n'
    printf '%s\n' '============================================================'
    printf 'Mode:     %s\n' "${MODE}"
    printf 'Planned:  %d\n' "${planned}"
    printf 'Existing: %d\n' "${existing}"
    printf 'Created:  %d\n' "${created}"

    if [[ "${MODE}" == "dry-run" ]]; then
        printf 'Result:   No GitHub issues were modified.\n'
    else
        printf 'Result:   GitHub issue reconciliation completed.\n'
    fi
}

main "$@"

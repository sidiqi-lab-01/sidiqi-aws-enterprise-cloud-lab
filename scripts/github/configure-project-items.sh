#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly ISSUES_FILE="${REPO_ROOT}/config/github/issues.tsv"
readonly PROJECT_NUMBER="${PROJECT_NUMBER:-4}"

MODE="dry-run"

PLANNED=0
UPDATED=0
UNCHANGED=0
FAILED=0

usage() {
    cat <<EOF_USAGE
Usage:
  $(basename "$0") [--dry-run | --apply]

Modes:
  --dry-run   Compare desired and current Project metadata without modifying
              GitHub. This is the default.

  --apply     Reconcile Project metadata with config/github/issues.tsv.

Environment:
  PROJECT_NUMBER   GitHub organization Project number.
                   Default: 4
EOF_USAGE
}

parse_args() {
    if (( $# > 1 )); then
        usage
        exit 2
    fi

    if (( $# == 1 )); then
        case "$1" in
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
                usage
                exit 2
                ;;
        esac
    fi
}

require_file() {
    local file="$1"

    if [[ ! -f "${file}" ]]; then
        fail "Required file not found: ${file}"
    fi
}

get_project_fields() {
    gh project field-list "${PROJECT_NUMBER}" \
        --owner "${GITHUB_ORG}" \
        --format json \
        --limit 100
}

get_project_items() {
    gh project item-list "${PROJECT_NUMBER}" \
        --owner "${GITHUB_ORG}" \
        --format json \
        --limit 200
}

resolve_field_id() {
    local fields_json="$1"
    local field_name="$2"

    jq -r \
        --arg field "${field_name}" \
        '.fields[]
         | select(.name == $field)
         | .id' \
        <<<"${fields_json}" |
        head -n 1
}

resolve_option_id() {
    local fields_json="$1"
    local field_name="$2"
    local option_name="$3"

    jq -r \
        --arg field "${field_name}" \
        --arg option "${option_name}" \
        '.fields[]
         | select(.name == $field)
         | .options[]
         | select(.name == $option)
         | .id' \
        <<<"${fields_json}" |
        head -n 1
}

get_repository_issues() {
    gh api \
        "repos/${GITHUB_ORG}/${GITHUB_REPO}/issues?state=all&per_page=100"
}

find_issue_number_by_key() {
    local issues_json="$1"
    local key="$2"
    local marker

    marker="Project work item: \`${key}\`"

    jq -r \
        --arg marker "${marker}" '
          .[]
          | select(.pull_request == null)
          | select((.body // "") | contains($marker))
          | .number
        ' \
        <<<"${issues_json}"
}

resolve_project_item_id() {
    local items_json="$1"
    local issue_number="$2"

    jq -r \
        --argjson number "${issue_number}" \
        '.items[]
         | select(
             .content.type == "Issue" and
             .content.number == $number
           )
         | .id' \
        <<<"${items_json}" |
        head -n 1
}

get_current_value() {
    local items_json="$1"
    local issue_number="$2"
    local field_name="$3"

    jq -r \
        --argjson number "${issue_number}" \
        --arg field "${field_name}" '
          .items[]
          | select(
              .content.type == "Issue" and
              .content.number == $number
            )
          | to_entries[]
          | select((.key | ascii_downcase) == ($field | ascii_downcase))
          | .value // ""
        ' \
        <<<"${items_json}"
}
set_single_select_value() {
    local project_id="$1"
    local item_id="$2"
    local field_id="$3"
    local option_id="$4"

    gh project item-edit \
        --id "${item_id}" \
        --project-id "${project_id}" \
        --field-id "${field_id}" \
        --single-select-option-id "${option_id}" \
        >/dev/null
}

main() {
    local fields_json
    local items_json
    local issues_json
    local project_id

    local key
    local title
    local milestone
    local priority
    local domain
    local work_type
    local phase
    local effort
    local risk
    local environment
    local labels

    local issue_number
    local item_id

    local field_name
    local desired_value
    local field_id
    local option_id
    local current_value

    parse_args "$@"

    initialize_github_automation

    require_command gh
    require_command jq
    require_command awk
    require_file "${ISSUES_FILE}"

    log "Configuring GitHub Project item metadata"
    log "Organization: ${GITHUB_ORG}"
    log "Project:      #${PROJECT_NUMBER}"
    log "Mode:         ${MODE}"
    log "Configuration: ${ISSUES_FILE}"

    fields_json="$(get_project_fields)"
    items_json="$(get_project_items)"
    issues_json="$(get_repository_issues)"

    project_id="$(
        gh api graphql \
            -f query='
query($org: String!, $number: Int!) {
  organization(login: $org) {
    projectV2(number: $number) {
      id
    }
  }
}' \
            -f org="${GITHUB_ORG}" \
            -F number="${PROJECT_NUMBER}" \
            --jq '.data.organization.projectV2.id'
    )"

    if [[ -z "${project_id}" || "${project_id}" == "null" ]]; then
        fail "Unable to resolve Project #${PROJECT_NUMBER} ID."
    fi

    while IFS=$'\t' read -r \
        key \
        title \
        _milestone \
        priority \
        domain \
        work_type \
        phase \
        effort \
        risk \
        environment \
        _labels
    do
        [[ -z "${key}" ]] && continue

        issue_number="$(find_issue_number_by_key "${issues_json}" "${key}")"

        if [[ -z "${issue_number}" ]]; then
            warn "Issue not found for work-item key: ${key}"
            ((FAILED += 1))
            continue
        fi

        item_id="$(resolve_project_item_id "${items_json}" "${issue_number}")"

        if [[ -z "${item_id}" ]]; then
            warn "Project item not found: ${key} (#${issue_number})"
            ((FAILED += 1))
            continue
        fi

        log "ITEM: ${key} (#${issue_number}) - ${title}"

        while IFS=$'\t' read -r field_name desired_value; do
            field_id="$(resolve_field_id "${fields_json}" "${field_name}")"

            if [[ -z "${field_id}" ]]; then
                warn "Field not found: ${field_name}"
                ((FAILED += 1))
                continue
            fi

            option_id="$(
                resolve_option_id \
                    "${fields_json}" \
                    "${field_name}" \
                    "${desired_value}"
            )"

            if [[ -z "${option_id}" ]]; then
                warn "Option not found: ${field_name}=${desired_value}"
                ((FAILED += 1))
                continue
            fi

            current_value="$(
                get_current_value \
                    "${items_json}" \
                    "${issue_number}" \
                    "${field_name}"
            )"

            if [[ "${current_value}" == "${desired_value}" ]]; then
                log "  UNCHANGED: ${field_name}=${desired_value}"
                ((UNCHANGED += 1))
                continue
            fi

            if [[ "${MODE}" == "dry-run" ]]; then
                log "  WOULD UPDATE: ${field_name}: '${current_value}' -> '${desired_value}'"
                ((PLANNED += 1))
                continue
            fi

            log "  UPDATE: ${field_name}: '${current_value}' -> '${desired_value}'"

            if set_single_select_value \
                "${project_id}" \
                "${item_id}" \
                "${field_id}" \
                "${option_id}"
            then
                ((UPDATED += 1))
            else
                warn "Failed: ${key} ${field_name}=${desired_value}"
                ((FAILED += 1))
            fi

        done < <(
            printf '%s\t%s\n' \
                "Priority" "${priority}" \
                "Domain" "${domain}" \
                "Work Type" "${work_type}" \
                "Phase" "${phase}" \
                "Effort" "${effort}" \
                "Risk" "${risk}" \
                "Environment" "${environment}"
        )

    done < <(tail -n +2 "${ISSUES_FILE}")

    printf '\n'
    printf '%s\n' "============================================================"
    printf 'Mode:      %s\n' "${MODE}"
    printf 'Planned:   %d\n' "${PLANNED}"
    printf 'Updated:   %d\n' "${UPDATED}"
    printf 'Unchanged: %d\n' "${UNCHANGED}"
    printf 'Failed:    %d\n' "${FAILED}"
    printf '%s\n' "============================================================"

    if (( FAILED > 0 )); then
        return 1
    fi

    log "GitHub Project item metadata reconciliation completed successfully."
}

main "$@"

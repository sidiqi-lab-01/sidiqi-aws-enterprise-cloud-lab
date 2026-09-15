#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly VIEWS_FILE="${REPO_ROOT}/config/github/project-views.tsv"
readonly PROJECT_NUMBER="${PROJECT_NUMBER:-4}"
readonly GITHUB_API_VERSION="${GITHUB_API_VERSION:-2026-03-10}"

CREATED=0
UNCHANGED=0
FAILED=0

usage() {
    cat <<EOF_USAGE
Usage:
  $(basename "$0")

Environment variables:
  PROJECT_NUMBER       GitHub organization Project number.
                       Default: 4

  GITHUB_API_VERSION   GitHub REST API version.
                       Default: 2026-03-10

Example:
  PROJECT_NUMBER=4 $(basename "$0")
EOF_USAGE
}

require_file() {
    local file="$1"

    if [[ ! -f "${file}" ]]; then
        fail "Required file not found: ${file}"
    fi
}

validate_views_header() {
    local expected
    local actual

    expected=$'name\tlayout\tfilter'
    actual="$(head -n 1 "${VIEWS_FILE}")"

    if [[ "${actual}" != "${expected}" ]]; then
        fail "Invalid project views header."
    fi
}

get_existing_views() {
    gh api graphql \
        -f query='
query($org: String!, $number: Int!) {
  organization(login: $org) {
    projectV2(number: $number) {
      id
      views(first: 100) {
        nodes {
          id
          number
          name
          layout
          filter
        }
      }
    }
  }
}' \
        -f org="${GITHUB_ORG}" \
        -F number="${PROJECT_NUMBER}"
}

normalize_layout() {
    local layout="$1"

    case "${layout}" in
        table)
            printf '%s\n' "TABLE_LAYOUT"
            ;;
        board)
            printf '%s\n' "BOARD_LAYOUT"
            ;;
        roadmap)
            printf '%s\n' "ROADMAP_LAYOUT"
            ;;
        *)
            return 1
            ;;
    esac
}

create_view() {
    local name="$1"
    local layout="$2"
    local filter="$3"

    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: ${GITHUB_API_VERSION}" \
        "/orgs/${GITHUB_ORG}/projectsV2/${PROJECT_NUMBER}/views" \
        -f name="${name}" \
        -f layout="${layout}" \
        -f filter="${filter}" \
        >/dev/null
}

main() {
    local existing_json
    local name
    local layout
    local filter
    local expected_layout
    local existing_record
    local existing_layout
    local existing_filter

    initialize_github_automation

    require_command jq
    require_file "${VIEWS_FILE}"
    validate_views_header

    log "Managing GitHub Project views"
    log "Organization: ${GITHUB_ORG}"
    log "Project:      #${PROJECT_NUMBER}"
    log "Configuration: ${VIEWS_FILE}"

    existing_json="$(get_existing_views)"

    if [[ "$(jq -r '.data.organization.projectV2.id // empty' <<<"${existing_json}")" == "" ]]; then
        fail "Unable to resolve Project #${PROJECT_NUMBER} for ${GITHUB_ORG}."
    fi

    while IFS=$'\t' read -r name layout filter; do
        [[ -z "${name}" ]] && continue

        if ! expected_layout="$(normalize_layout "${layout}")"; then
            warn "Unsupported layout '${layout}' for view '${name}'."
            ((FAILED += 1))
            continue
        fi

        existing_record="$(
            jq -c \
                --arg name "${name}" \
                '.data.organization.projectV2.views.nodes[]
                 | select(.name == $name)' \
                <<<"${existing_json}" |
            head -n 1
        )"

        if [[ -z "${existing_record}" ]]; then
            log "CREATE: ${name}"

            if create_view "${name}" "${layout}" "${filter}"; then
                ((CREATED += 1))
            else
                warn "Failed to create view: ${name}"
                ((FAILED += 1))
            fi

            continue
        fi

        existing_layout="$(jq -r '.layout // ""' <<<"${existing_record}")"
        existing_filter="$(jq -r '.filter // ""' <<<"${existing_record}")"

        if [[ "${existing_layout}" == "${expected_layout}" &&
              "${existing_filter}" == "${filter}" ]]; then
            log "UNCHANGED: ${name}"
            ((UNCHANGED += 1))
        else
            warn "DRIFT: ${name}"
            warn "  Expected layout: ${expected_layout}"
            warn "  Actual layout:   ${existing_layout}"
            warn "  Expected filter: ${filter}"
            warn "  Actual filter:   ${existing_filter}"
            warn "  Existing views are not modified automatically."
            ((FAILED += 1))
        fi
    done < <(tail -n +2 "${VIEWS_FILE}")

    printf '\n'
    printf '%s\n' "============================================================"
    printf 'Created:   %d\n' "${CREATED}"
    printf 'Unchanged: %d\n' "${UNCHANGED}"
    printf 'Failed:    %d\n' "${FAILED}"
    printf '%s\n' "============================================================"

    if (( FAILED > 0 )); then
        return 1
    fi

    log "GitHub Project view reconciliation completed successfully."
}

main "$@"

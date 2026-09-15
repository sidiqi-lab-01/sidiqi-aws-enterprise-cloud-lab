#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly PROJECT_CONFIG="${REPO_ROOT}/config/github/project.conf"
readonly FIELD_CONFIG="${REPO_ROOT}/config/github/project-fields.tsv"

initialize_github_automation
require_command jq

[[ -f "${PROJECT_CONFIG}" ]] ||
    fail "Project configuration not found: ${PROJECT_CONFIG}"

[[ -f "${FIELD_CONFIG}" ]] ||
    fail "Project field configuration not found: ${FIELD_CONFIG}"

# shellcheck disable=SC1090
source "${PROJECT_CONFIG}"

project_number="$(
    gh project list \
        --owner "${GITHUB_ORG}" \
        --format json \
        --jq ".projects[] | select(.title == \"${PROJECT_TITLE}\") | .number"
)"

[[ -n "${project_number}" ]] ||
    fail "Project not found: ${PROJECT_TITLE}"

created=0
unchanged=0

while IFS=$'\t' read -r name data_type options; do
    [[ -n "${name}" ]] || continue
    [[ "${name}" == \#* ]] && continue

    existing="$(
        gh project field-list "${project_number}" \
            --owner "${GITHUB_ORG}" \
            --format json \
            --jq ".fields[] | select(.name == \"${name}\") | .name"
    )"

    if [[ -n "${existing}" ]]; then
        log "Field already exists: ${name}"
        ((unchanged += 1))
        continue
    fi

    log "Creating field: ${name}"

    if [[ "${data_type}" == "SINGLE_SELECT" ]]; then
        gh project field-create "${project_number}" \
            --owner "${GITHUB_ORG}" \
            --name "${name}" \
            --data-type "${data_type}" \
            --single-select-options "${options}" \
            >/dev/null
    else
        gh project field-create "${project_number}" \
            --owner "${GITHUB_ORG}" \
            --name "${name}" \
            --data-type "${data_type}" \
            >/dev/null
    fi

    ((created += 1))
done < "${FIELD_CONFIG}"

log "Project field reconciliation complete."
log "Created: ${created}"
log "Unchanged: ${unchanged}"

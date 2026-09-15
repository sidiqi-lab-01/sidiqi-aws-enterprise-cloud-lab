#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly LABEL_CONFIG="${REPO_ROOT}/config/github/labels.tsv"

initialize_github_automation

[[ -f "${LABEL_CONFIG}" ]] ||
    fail "Label configuration not found: ${LABEL_CONFIG}"

created=0
updated=0
unchanged=0

while IFS=$'\t' read -r name color description; do
    [[ -n "${name}" ]] || continue
    [[ "${name}" == \#* ]] && continue

    if [[ -z "${color}" || -z "${description}" ]]; then
        fail "Invalid label configuration for: ${name}"
    fi

    existing="$(
        gh label list \
            --repo "${GITHUB_REPOSITORY}" \
            --limit 1000 \
            --json name,color,description \
            --jq ".[] | select(.name == \"${name}\") | [.color, .description] | @tsv"
    )"

    if [[ -z "${existing}" ]]; then
        log "Creating label: ${name}"

        gh label create "${name}" \
            --repo "${GITHUB_REPOSITORY}" \
            --color "${color}" \
            --description "${description}"

        ((created += 1))
        continue
    fi

    IFS=$'\t' read -r existing_color existing_description <<< "${existing}"

    if [[ "${existing_color,,}" == "${color,,}" &&
          "${existing_description}" == "${description}" ]]; then
        log "Label already correct: ${name}"
        ((unchanged += 1))
        continue
    fi

    log "Updating label: ${name}"

    gh label edit "${name}" \
        --repo "${GITHUB_REPOSITORY}" \
        --color "${color}" \
        --description "${description}"

    ((updated += 1))
done < "${LABEL_CONFIG}"

log "Label reconciliation complete."
log "Created: ${created}"
log "Updated: ${updated}"
log "Unchanged: ${unchanged}"

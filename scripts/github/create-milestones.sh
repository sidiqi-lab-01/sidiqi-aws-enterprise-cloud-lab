#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly MILESTONE_CONFIG="${REPO_ROOT}/config/github/milestones.tsv"

initialize_github_automation
require_command jq

[[ -f "${MILESTONE_CONFIG}" ]] ||
    fail "Milestone configuration not found: ${MILESTONE_CONFIG}"

created=0
updated=0
unchanged=0

while IFS=$'\t' read -r title description; do
    [[ -n "${title}" ]] || continue
    [[ "${title}" == \#* ]] && continue

    [[ -n "${description}" ]] ||
        fail "Missing milestone description: ${title}"

    milestone_json="$(
        gh api \
            --paginate \
            "repos/${GITHUB_REPOSITORY}/milestones?state=all&per_page=100" \
            --jq ".[] | select(.title == \"${title}\")"
    )"

    if [[ -z "${milestone_json}" ]]; then
        log "Creating milestone: ${title}"

        gh api \
            --method POST \
            "repos/${GITHUB_REPOSITORY}/milestones" \
            -f title="${title}" \
            -f description="${description}" \
            >/dev/null

        ((created += 1))
        continue
    fi

    number="$(jq -r '.number' <<< "${milestone_json}")"
    existing_description="$(jq -r '.description // ""' <<< "${milestone_json}")"
    existing_state="$(jq -r '.state' <<< "${milestone_json}")"

    if [[ "${existing_description}" == "${description}" &&
          "${existing_state}" == "open" ]]; then
        log "Milestone already correct: ${title}"
        ((unchanged += 1))
        continue
    fi

    log "Updating milestone: ${title}"

    gh api \
        --method PATCH \
        "repos/${GITHUB_REPOSITORY}/milestones/${number}" \
        -f title="${title}" \
        -f description="${description}" \
        -f state='open' \
        >/dev/null

    ((updated += 1))
done < "${MILESTONE_CONFIG}"

log "Milestone reconciliation complete."
log "Created: ${created}"
log "Updated: ${updated}"
log "Unchanged: ${unchanged}"

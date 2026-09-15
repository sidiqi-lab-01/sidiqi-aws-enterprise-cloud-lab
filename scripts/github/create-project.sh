#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly PROJECT_CONFIG="${REPO_ROOT}/config/github/project.conf"
readonly PROJECT_README="${REPO_ROOT}/config/github/project-readme.md"

initialize_github_automation
require_command jq

[[ -f "${PROJECT_CONFIG}" ]] ||
    fail "Project configuration not found: ${PROJECT_CONFIG}"

[[ -f "${PROJECT_README}" ]] ||
    fail "Project README not found: ${PROJECT_README}"

# shellcheck disable=SC1090
source "${PROJECT_CONFIG}"

: "${PROJECT_TITLE:?PROJECT_TITLE must be configured}"
: "${PROJECT_SHORT_DESCRIPTION:?PROJECT_SHORT_DESCRIPTION must be configured}"

project_json="$(
    gh project list \
        --owner "${GITHUB_ORG}" \
        --format json \
        --jq ".projects[] | select(.title == \"${PROJECT_TITLE}\")"
)"

if [[ -z "${project_json}" ]]; then
    log "Creating organization project: ${PROJECT_TITLE}"

    project_json="$(
        gh project create \
            --owner "${GITHUB_ORG}" \
            --title "${PROJECT_TITLE}" \
            --format json
    )"

    project_number="$(jq -r '.number' <<< "${project_json}")"

    log "Created project #${project_number}"
else
    project_number="$(jq -r '.number' <<< "${project_json}")"
    log "Project already exists: #${project_number} ${PROJECT_TITLE}"
fi

project_readme="$(cat "${PROJECT_README}")"

log "Reconciling project metadata."

gh project edit "${project_number}" \
    --owner "${GITHUB_ORG}" \
    --title "${PROJECT_TITLE}" \
    --description "${PROJECT_SHORT_DESCRIPTION}" \
    --readme "${project_readme}" \
    --visibility PUBLIC \
    >/dev/null

log "Linking project to repository."

if ! gh project link "${project_number}" \
    --owner "${GITHUB_ORG}" \
    --repo "${GITHUB_REPOSITORY}" 2>/dev/null; then
    warn "Project link may already exist or could not be changed."
fi

log "Project reconciliation complete."
log "Project number: ${project_number}"

#!/usr/bin/env bash
set -Eeuo pipefail

readonly GITHUB_ORG="${GITHUB_ORG:-sidiqi-lab-01}"
readonly GITHUB_REPO="${GITHUB_REPO:-sidiqi-aws-enterprise-cloud-lab}"
readonly GITHUB_REPOSITORY="${GITHUB_ORG}/${GITHUB_REPO}"

log() {
    printf '[github-automation] %s\n' "$*"
}

warn() {
    printf '[github-automation] WARNING: %s\n' "$*" >&2
}

fail() {
    printf '[github-automation] ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    local command_name="$1"

    command -v "${command_name}" >/dev/null 2>&1 ||
        fail "Required command not found: ${command_name}"
}

validate_dependencies() {
    require_command git
    require_command gh
}

validate_git_repository() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
        fail "Current directory is not a Git repository."
}

validate_github_authentication() {
    gh auth status >/dev/null 2>&1 ||
        fail "GitHub CLI authentication validation failed."
}

validate_repository_access() {
    local actual_repository

    actual_repository="$(
        gh repo view "${GITHUB_REPOSITORY}" \
            --json nameWithOwner \
            --jq '.nameWithOwner'
    )"

    [[ "${actual_repository}" == "${GITHUB_REPOSITORY}" ]] ||
        fail "Repository validation failed. Expected ${GITHUB_REPOSITORY}, got ${actual_repository}."
}

validate_not_main() {
    local current_branch

    current_branch="$(git branch --show-current)"

    [[ "${current_branch}" != "main" ]] ||
        fail "Refusing project-management changes directly from main."
}

initialize_github_automation() {
    validate_dependencies
    validate_git_repository
    validate_github_authentication
    validate_repository_access
    validate_not_main

    log "Organization: ${GITHUB_ORG}"
    log "Repository: ${GITHUB_REPOSITORY}"
    log "Branch: $(git branch --show-current)"
}

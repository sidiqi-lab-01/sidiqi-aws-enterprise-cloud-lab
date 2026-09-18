#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

log() {
    printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

fail() {
    printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log "Starting repository validation."

command_exists git || fail "Git is not installed."

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" ||
    fail "This script must be executed from inside a Git repository."

cd "$repo_root"

current_branch="$(git branch --show-current)"

log "Repository: $repo_root"
log "Branch: $current_branch"

if [[ "$current_branch" == "main" ]]; then
    log "WARNING: currently on main. Normal implementation work should use a feature branch."
fi

log "Checking unstaged Git whitespace errors."

if ! git diff --check; then
    fail "Unstaged whitespace validation failed."
fi

log "Checking staged Git whitespace errors."

if ! git diff --cached --check; then
    fail "Staged whitespace validation failed."
fi

log "Checking tracked files for sensitive file types."

sensitive_files="$(
    git ls-files |
        grep -E '(^|/)([^/]+\.pem|[^/]+\.key|[^/]+\.p12|[^/]+\.pfx|[^/]+\.tfstate(\..*)?|[^/]+\.tfvars(\.json)?|\.env|credentials|kubeconfig|[^/]+\.kubeconfig)$' ||
        true
)"

if [[ -n "$sensitive_files" ]]; then
    printf '%s\n' "$sensitive_files" >&2
    fail "Potentially sensitive tracked files were found."
fi

log "Checking required repository files."

required_files=(
    "README.md"
    ".gitignore"
    "COMMANDS.md"
    "docs/workflows/development-workflow.md"
    "docs/standards/branching-standard.md"
    "docs/standards/commit-standard.md"
    "docs/standards/documentation-standard.md"
    "docs/standards/scripting-standard.md"
)

for file in "${required_files[@]}"; do
    [[ -f "$file" ]] || fail "Required file is missing: $file"
done

log "Repository validation completed successfully."

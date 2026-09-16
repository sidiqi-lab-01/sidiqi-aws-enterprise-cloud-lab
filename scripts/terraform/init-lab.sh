#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/terraform/bootstrap/backend"
LAB_DIR="${REPO_ROOT}/terraform/environments/lab"

command -v terraform >/dev/null 2>&1 || {
  echo "ERROR: terraform is required." >&2
  exit 1
}

STATE_BUCKET="$(
  terraform -chdir="${BOOTSTRAP_DIR}" output -raw state_bucket_name
)"

if [[ -z "${STATE_BUCKET}" ]]; then
  echo "ERROR: Terraform state bucket output is empty." >&2
  exit 1
fi

echo "Initializing lab Terraform backend..."

init_args=(
  -backend-config="bucket=${STATE_BUCKET}"
)

if init_output="$(
  terraform -chdir="${LAB_DIR}" init "${init_args[@]}" 2>&1
)"; then
  [[ -n "${init_output}" ]] && printf '%s\n' "${init_output}"
elif [[ "${init_output}" == *"Backend configuration changed"* ]]; then
  printf '%s\n' "${init_output}" >&2
  terraform -chdir="${LAB_DIR}" init -migrate-state "${init_args[@]}"
else
  printf '%s\n' "${init_output}" >&2
  exit 1
fi

echo "Lab Terraform backend initialized successfully."

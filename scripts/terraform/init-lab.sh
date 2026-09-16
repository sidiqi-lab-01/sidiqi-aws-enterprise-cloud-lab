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

if [[ -f "${LAB_DIR}/.terraform/terraform.tfstate" ]]; then
  init_args=(-migrate-state "${init_args[@]}")
fi

terraform -chdir="${LAB_DIR}" init "${init_args[@]}"

echo "Lab Terraform backend initialized successfully."

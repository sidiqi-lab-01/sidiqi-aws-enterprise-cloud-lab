#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/terraform/bootstrap/backend"
LAB_DIR="${REPO_ROOT}/terraform/environments/lab"

command -v terraform >/dev/null 2>&1 || {
  echo "ERROR: terraform is required." >&2
  exit 1
}

if [[ ! -f "${BOOTSTRAP_DIR}/terraform.tfstate" ]]; then
  echo "ERROR: Backend bootstrap state was not found." >&2
  echo "Create the backend infrastructure before initializing the lab environment." >&2
  exit 1
fi

STATE_BUCKET="$(
  terraform -chdir="${BOOTSTRAP_DIR}" output -raw state_bucket_name
)"

if [[ -z "${STATE_BUCKET}" ]]; then
  echo "ERROR: Terraform state bucket output is empty." >&2
  exit 1
fi

echo "Initializing lab Terraform backend..."
echo "State bucket is obtained from the backend bootstrap output."

terraform -chdir="${LAB_DIR}" init \
  -backend-config="bucket=${STATE_BUCKET}"

echo "Lab Terraform backend initialized successfully."

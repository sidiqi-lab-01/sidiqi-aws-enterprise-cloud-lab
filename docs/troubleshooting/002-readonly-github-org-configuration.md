# Troubleshooting: Readonly GitHub Organization Configuration

## Problem

The GitHub project creation automation failed before creating the organization project.

## Error

```text
config/github/project.conf: line 1: GITHUB_ORG: readonly variable
Context

The automation loaded:

scripts/github/lib/common.sh
config/github/project.conf

The shared library defined repository identity variables as readonly:

readonly GITHUB_ORG="${GITHUB_ORG:-sidiqi-lab-01}"
readonly GITHUB_REPO="${GITHUB_REPO:-sidiqi-aws-enterprise-cloud-lab}"
readonly GITHUB_REPOSITORY="${GITHUB_ORG}/${GITHUB_REPO}"

The project configuration subsequently attempted to assign GITHUB_ORG and GITHUB_REPO again.

Root Cause

Configuration ownership was duplicated.

Repository and organization identity were already initialized and made readonly by common.sh, but project.conf attempted to redefine the same variables.

Bash prevents reassignment of readonly variables.

Resolution

Removed GITHUB_ORG and GITHUB_REPO from config/github/project.conf.

The project configuration now contains only project-specific settings:

PROJECT_TITLE="Sidiqi AWS Enterprise Cloud Lab"
PROJECT_SHORT_DESCRIPTION="Enterprise AWS, DevSecOps, Kubernetes, security, automation, observability, disaster recovery, and FinOps engineering portfolio lab."

Repository identity remains centrally managed by scripts/github/lib/common.sh.

Validation

Validate script syntax:

bash -n scripts/github/create-project.sh

Validate the project configuration can be loaded after the shared library:

bash -c '
source scripts/github/lib/common.sh
source config/github/project.conf
printf "Organization: %s\n" "$GITHUB_ORG"
printf "Repository: %s\n" "$GITHUB_REPOSITORY"
printf "Project: %s\n" "$PROJECT_TITLE"
'
Prevention

Maintain a single source of ownership for configuration variables.

Shared repository identity belongs to common.sh.

Project-specific metadata belongs to project.conf.

Avoid redefining readonly shared configuration in component-specific configuration files.

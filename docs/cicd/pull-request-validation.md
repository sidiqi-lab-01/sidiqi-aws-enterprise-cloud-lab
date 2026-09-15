# Pull Request Validation

## Purpose

Pull Requests targeting `main` are automatically validated using GitHub
Actions.

The objective is to detect quality, security, scripting, and repository
problems before changes are merged.

## Workflow

Workflow file:

```text
.github/workflows/pr-validation.yml
Trigger

The workflow executes for Pull Requests targeting:

main
Current Checks
Repository Validation

Runs:

./scripts/validation/validate-repository.sh

This reuses the same validation script available to developers locally.

ShellCheck

Shell scripts under scripts/ are analyzed using ShellCheck.

ShellCheck helps identify common shell scripting problems and unsafe
patterns.

Local and CI Consistency

The project intentionally reuses validation logic where practical:

Local Development
       |
       v
Reusable Validation Script
       ^
       |
GitHub Actions

This reduces differences between local validation and CI validation.

Security

The workflow currently uses:

permissions:
  contents: read

The principle of least privilege should be used when GitHub Actions
permissions are expanded.

Secrets must not be printed to workflow logs.

Future Checks

As the project grows, Pull Request validation may include:

Terraform fmt
Terraform validate
Terraform security scanning
Secret scanning
YAML validation
Kubernetes manifest validation
Helm validation
Policy checks
Documentation validation
Unit tests
Application tests
Merge Requirement

Required CI checks should pass before a Pull Request is merged into
main.

Automated checks supplement rather than replace human engineering review.

# Commit Standard

## Purpose

This document defines commit-message and commit-quality standards.

## Format

The preferred format is:

```text
<type>(<scope>): <description> (#<issue>)
Examples:

feat(networking): add VPC foundation (#10)
fix(terraform): correct private route configuration (#14)
docs(workflow): document development lifecycle (#1)
security(iam): restrict deployment role permissions (#32)
ci(terraform): add pull request validation (#41)
Common Types
Type	Purpose
feat	New functionality
fix	Bug correction
docs	Documentation
ci	CI/CD changes
test	Tests or validation
refactor	Internal restructuring
security	Security improvement
chore	Maintenance
build	Build/dependency changes
Commit Requirements

Before committing:

git status
git diff
git diff --check

After staging:

git diff --cached
git status

A commit should:

Represent a coherent change.
Have a meaningful message.
Reference the issue where appropriate.
Include required documentation.
Avoid unrelated modifications.
Contain no credentials or secrets.
Pass applicable local validation.
Prohibited Content

Never intentionally commit:

Passwords
AWS access keys
AWS secret keys
AWS session tokens
GitHub tokens
Private SSH keys
PEM private keys
Sensitive Terraform state
Sensitive tfvars files
Kubeconfig credentials
Application secrets
History

Do not rewrite shared history casually.

Force pushes should be avoided unless there is a documented reason and
the impact is understood.

# Development Workflow

## Purpose

This document defines the standard engineering workflow for the
Sidiqi AWS Enterprise Cloud Lab.

The objective is to ensure that infrastructure, automation, security,
documentation, and application changes are traceable, reviewable,
repeatable, and validated before they are merged into the main branch.

---

## Core Engineering Principles

The project follows these principles:

1. Requirements are tracked through GitHub Issues.
2. Implementation work is performed on feature branches.
3. Repeatable operations should be automated.
4. Infrastructure should be defined as code where practical.
5. Commands used during implementation must be documented.
6. Technical decisions and architecture must be documented.
7. Changes must be validated locally before being pushed.
8. Security checks must be performed before merge.
9. Changes enter the main branch through Pull Requests.
10. Automated CI checks must validate Pull Requests.
11. GitHub Copilot may provide AI-assisted Pull Request review.
12. Human engineering judgment remains responsible for final approval.
13. Feature branches should be deleted after successful merge.
14. Issues should be closed when their acceptance criteria are satisfied.

---

## Standard Development Lifecycle

```text
Requirement
    |
    v
GitHub Issue
    |
    v
Feature Branch
    |
    v
Implementation
    |
    +---- Infrastructure as Code
    |
    +---- Reusable Scripts
    |
    +---- Configuration
    |
    +---- Documentation
    |
    v
Local Validation
    |
    v
Security Validation
    |
    v
Commit
    |
    v
Push
    |
    v
Pull Request
    |
    +---- GitHub Actions
    |
    +---- Automated Validation
    |
    +---- Security Checks
    |
    +---- Copilot Review
    |
    v
Human Review
    |
    v
Merge to main
    |
    v
Delete Feature Branch
    |
    v
Close GitHub Issue
1. Requirement Definition

Every significant project change begins with a clearly defined requirement.

Requirements may originate from:

Architecture objectives
AWS service implementation
Security requirements
Operational requirements
Automation opportunities
Monitoring requirements
Troubleshooting findings
Documentation improvements
Application requirements
Infrastructure improvements

The requirement should describe the desired outcome before implementation
begins.

2. GitHub Issue

A GitHub Issue is created for each significant unit of work.

Each issue should contain:

Objective
Background
Requirements
Deliverables
Security considerations
Validation requirements
Acceptance criteria

Issues provide traceability between the original requirement and the
implementation.

3. Feature Branch

Implementation must occur on a dedicated feature branch.

Branch naming convention:

feature/<issue-number>-<short-description>

Example:

feature/1-project-engineering-workflow
feature/10-vpc-foundation
feature/25-eks-cluster

Before creating a feature branch:

git checkout main
git pull origin main
git status

Create the branch:

git checkout -b feature/<issue-number>-<description>

Push the branch:

git push -u origin feature/<issue-number>-<description>

Direct implementation commits to main are not part of the normal
development workflow.

4. Implementation

Implementation may include:

Terraform
Ansible
Bash
Python
AWS CLI
Kubernetes manifests
Helm charts
Argo CD configuration
GitHub Actions
Application code
Security configuration
Monitoring configuration
Documentation

Implementation should favor repeatable and automated methods over
one-time manual procedures.

5. Reusable Automation

Commands that are repeatedly required should be evaluated for conversion
into reusable scripts or automation.

Scripts should:

Validate input
Fail safely
Return meaningful exit codes
Produce understandable output
Avoid hard-coded credentials
Be reusable across environments where practical
Be documented
Be tested before merge

Shell scripts should normally use strict error handling:

set -Eeuo pipefail
6. Command Documentation

Commands used to build, validate, troubleshoot, operate, and destroy
project resources must be documented.

Detailed command documentation is maintained under:

docs/commands/

Command documentation should include:

Command
Purpose
Prerequisites
Parameters
Explanation
Expected result
Validation
Security considerations
Common failures
Troubleshooting guidance

Secrets must never be copied into command documentation.

7. Technical Documentation

Each significant implementation should document:

Purpose
Architecture
Design decisions
Dependencies
Configuration
Deployment
Validation
Security considerations
Cost considerations
Troubleshooting
Rollback or cleanup
Lessons learned

Documentation is developed alongside the implementation rather than
being reconstructed after implementation is complete.

8. Local Validation

Changes must be validated before they are pushed.

Examples include:

git status
git diff
terraform fmt -check
terraform validate
shellcheck <script>

Additional validation depends on the technology being changed.

9. Security Validation

Before committing or pushing changes, verify that sensitive information
has not been introduced.

Examples of prohibited repository content include:

AWS secret access keys
AWS session tokens
GitHub tokens
Passwords
Private SSH keys
PEM private keys
Terraform state containing sensitive information
Sensitive tfvars files
Kubeconfig credentials
Application secrets

Automated secret scanning and Infrastructure as Code security scanning
will be incorporated into the CI/CD pipeline.

10. Commit

Review changes before committing:

git status
git diff

Stage intended files:

git add <files>

Commit messages should explain the type and purpose of the change.

Example:

git commit -m "docs(workflow): establish engineering development process (#1)"
11. Push

Push the feature branch:

git push

The feature branch remains separate from main until the Pull Request
process is complete.

12. Pull Request

A Pull Request is opened from the feature branch into main.

The Pull Request should describe:

What changed
Why the change was required
Related issue
Testing performed
Security impact
Documentation changes
Validation evidence

Where appropriate, the Pull Request should reference the issue using:

Closes #<issue-number>
13. Automated CI Validation

GitHub Actions will execute automated checks against Pull Requests.

Depending on the change, checks may include:

Repository validation
Terraform formatting
Terraform validation
Infrastructure security scanning
Secret detection
Shell script validation
Documentation checks
Kubernetes validation
Application testing

Failed required checks must be investigated before merge.

14. GitHub Copilot Review

GitHub Copilot may be used as an AI-assisted reviewer where supported and
configured.

Copilot review is intended to help identify:

Potential defects
Maintainability concerns
Security concerns
Missing validation
Documentation improvements
Infrastructure configuration issues

AI-generated recommendations must be evaluated by a human engineer.

Copilot approval or comments do not replace deterministic CI validation,
security controls, or human engineering judgment.

15. Human Review

The final review evaluates:

Requirement fulfillment
Architecture
Security
Reliability
Maintainability
Automation quality
Documentation quality
Validation results
Cost impact
Operational impact

Significant review findings should be resolved before merge.

16. Merge

After required checks and reviews are complete, the Pull Request may be
merged into main.

The repository may use squash merging to maintain a concise main branch
history.

17. Branch Cleanup

After successful merge, the remote feature branch should normally be
deleted.

The local repository should then return to main and synchronize:

git checkout main
git pull origin main
git branch -d feature/<issue-number>-<description>
18. Issue Closure

The issue is closed after:

Acceptance criteria are satisfied
Required documentation exists
Automated validation passes
Review is complete
The implementation has been merged

If the Pull Request contains:

Closes #<issue-number>

GitHub can automatically close the issue when the Pull Request is merged.

Troubleshooting and Lessons Learned

Failures encountered during implementation should be documented rather
than hidden.

Troubleshooting documentation should capture:

Problem
    |
    v
Symptoms / Error
    |
    v
Diagnostic Commands
    |
    v
Evidence
    |
    v
Root Cause
    |
    v
Resolution
    |
    v
Validation
    |
    v
Prevention

This creates reusable operational knowledge for future engineering work.

Workflow Governance

This workflow applies to the AWS Enterprise Cloud Lab unless a documented
technical reason requires an exception.

Changes to this workflow should themselves follow the Issue → Feature
Branch → Pull Request → Review → Merge process.

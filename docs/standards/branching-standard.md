# Branching Standard

## Purpose

This document defines the Git branching strategy for the AWS Enterprise
Cloud Lab.

## Protected Primary Branch

`main` represents the approved project state.

Normal development must not be performed directly on `main`.

Changes should enter `main` through Pull Requests after required
validation and review.

## Standard Workflow

```text
main
 |
 +-- GitHub Issue
       |
       +-- feature/<issue>-<description>
                 |
                 +-- implementation
                 +-- testing
                 +-- documentation
                 |
                 +-- Pull Request
                       |
                       +-- CI checks
                       +-- security checks
                       +-- Copilot review
                       +-- human review
                       |
                       +-- merge to main
Branch Naming

Feature:

feature/<issue-number>-<description>

Examples:

feature/1-project-engineering-workflow
feature/10-vpc-foundation
feature/25-eks-cluster

Bug fix:

fix/<issue-number>-<description>

Documentation:

docs/<issue-number>-<description>

Security:

security/<issue-number>-<description>

Automation:

automation/<issue-number>-<description>
Creating a Branch

Always synchronize main first:

git checkout main
git pull origin main
git status

Create the branch:

git checkout -b feature/<issue-number>-<description>

Publish it:

git push -u origin feature/<issue-number>-<description>
Rules
One branch should represent one primary issue or logical change.
Branch names should reference the related issue.
Avoid unrelated changes on the same branch.
Keep branches reasonably short-lived.
Synchronize long-running branches with approved upstream changes.
Do not place credentials or secrets in branch names.
Do not merge a branch solely because automated checks pass.
Human engineering judgment remains required.
Branch Cleanup

After merge:

git checkout main
git pull origin main
git branch -d feature/<issue-number>-<description>

Remote feature branches should normally be deleted after successful merge.

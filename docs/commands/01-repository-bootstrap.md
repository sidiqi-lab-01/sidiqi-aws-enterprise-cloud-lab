# Repository Bootstrap Commands

## Purpose

This document records the commands used to initialize the AWS Enterprise
Cloud Lab repository and establish the first feature branch.

---

# 1. Create Project Directory

## Commands

```bash
cd ~

mkdir -p sidiqi-aws-enterprise-cloud-lab
cd sidiqi-aws-enterprise-cloud-lab
Purpose

Creates the local project workspace.

Project Path
/home/sidiqi/sidiqi-aws-enterprise-cloud-lab
2. Initialize Git Repository
Commands
git init
git branch -M main
Purpose

Initializes Git version control and establishes main as the primary
branch.

3. Verify Repository State
Commands
git status
pwd
git branch
Purpose

Confirms:

Repository initialization
Current branch
Working directory
Initial working-tree state
4. Create Bootstrap Files

The initial repository contained:

README.md
.gitignore

The README established the project's high-level purpose.

The .gitignore established initial protection against accidentally
committing:

Terraform state
Terraform variable files
Private keys
Environment files
AWS credential files
Kubernetes credential files
Logs
Temporary files
5. Review Changes
Commands
git status
git diff -- README.md .gitignore
Purpose

Reviews repository changes before staging.

This is an important safety practice because engineers should understand
what will enter version control before creating a commit.

6. Sensitive File Check
Command
find . -type f \
  \( -name "*.pem" \
  -o -name "*.key" \
  -o -name "*.tfstate" \
  -o -name "*.tfvars" \
  -o -name ".env" \
  -o -name "credentials" \)
Purpose

Performs an initial basic search for file types that may contain
credentials or sensitive infrastructure information.

Important Limitation

This command is only a basic local safety check.

It does not replace:

Secret scanning
GitHub secret scanning
Security review
IaC scanning
Manual inspection

Additional automated security controls will be added to the project.

7. Stage Bootstrap Files
Command
git add README.md .gitignore
Purpose

Stages only the intended bootstrap files.

8. Inspect Staging Area
Command
git status
Observed Files
new file: .gitignore
new file: README.md
9. Create Initial Commit
Command
git commit -m "chore: initialize AWS enterprise cloud lab"
Observed Commit
97c0f09 chore: initialize AWS enterprise cloud lab
Engineering Note

This root commit is a repository-bootstrap exception.

Normal implementation work after repository initialization follows:

Issue → Feature Branch → Pull Request → Review → Merge
10. Inspect Git History
Command
git log --oneline --decorate
Observed Result
97c0f09 (HEAD -> main) chore: initialize AWS enterprise cloud lab
11. Create GitHub Repository

The repository was created under the GitHub organization:

sidiqi-lab-01

Repository name:

sidiqi-aws-enterprise-cloud-lab

The local repository was configured with the GitHub repository as
origin.

12. Synchronize Main
Commands
git checkout main
git pull origin main
git status
Observed Result

The local main branch was synchronized with origin/main, and the
working tree was clean.

Why This Matters

Feature branches should normally begin from the latest approved version
of main.

13. Create Feature Branch
Command
git checkout -b feature/1-project-engineering-workflow
Purpose

Creates the implementation branch associated with GitHub Issue #1.

Branch Naming Pattern
feature/<issue-number>-<description>
14. Verify Feature Branch
Commands
git branch
git status
Observed Result
* feature/1-project-engineering-workflow
  main

The working tree remained clean.

15. Publish Feature Branch
Command
git push -u origin feature/1-project-engineering-workflow
Purpose

Publishes the feature branch to GitHub and establishes the upstream
tracking relationship.

16. Verify Tracking
Command
git branch -vv
Observed State

Both branches referenced the initial bootstrap commit:

feature/1-project-engineering-workflow 97c0f09
main                                   97c0f09

The feature branch tracked:

origin/feature/1-project-engineering-workflow

and main tracked:

origin/main
Current Workflow Position

At this stage:

Requirement
    |
    v
GitHub Issue #1
    |
    v
Feature Branch
    |
    v
Implementation  <-- CURRENT STAGE

All Issue #1 implementation work is performed on:

feature/1-project-engineering-workflow
Security Considerations

Before every commit:

Review git status.
Review git diff.
Check for unexpected files.
Check for credentials and secrets.
Never use broad staging blindly without reviewing the changes.
Never commit private keys, AWS credentials, GitHub tokens,
Terraform state containing sensitive values, or kubeconfig
credentials.
Lessons Learned

Repository initialization is intentionally separated from feature
implementation.

After the initial bootstrap commit, the project transitions to an
issue-driven Pull Request workflow so changes remain traceable and
reviewable.

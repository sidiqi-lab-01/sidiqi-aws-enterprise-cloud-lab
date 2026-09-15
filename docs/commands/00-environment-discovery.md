# Environment Discovery Commands

## Purpose

This document records the commands used to inspect and validate the
engineering environment before beginning the AWS Enterprise Cloud Lab.

Environment discovery is performed before making infrastructure changes
so that engineers understand the current operating environment,
installed tooling, authentication state, and repository context.

---

## Environment Summary

The initial project environment was validated with the following tooling:

| Component | Observed Value |
|---|---|
| Linux User | `sidiqi` |
| Host | `ip-172-31-16-171` |
| Working Directory | `/home/sidiqi` |
| Git | `2.43.0` |
| GitHub CLI | `2.45.0` |
| AWS CLI | `2.36.41` |
| Terraform | `1.16.1` |
| Platform | `linux_amd64` |
| GitHub Account | `sidiqi-lab` |
| GitHub Organization | `sidiqi-lab-01` |
| Organization Role | `admin` |

> Sensitive authentication values are intentionally excluded from this
> documentation.

---

# 1. Identify Current Linux User

## Command

```bash
whoami
Purpose

Displays the Linux account currently executing commands.

Observed Result
sidiqi
Why It Matters

The executing user affects:

File ownership
Filesystem permissions
SSH configuration
Git configuration
AWS CLI configuration
Kubernetes configuration
Docker access
Script execution
2. Identify Host
Command
hostname
Purpose

Displays the hostname of the current Linux system.

Observed Result
ip-172-31-16-171
Interpretation

The hostname format is consistent with an EC2 instance using an internal
private IP-based hostname.

The hostname alone should not be used as proof of AWS identity.
AWS identity should be independently validated through AWS CLI commands.

3. Display Working Directory
Command
pwd
Purpose

Displays the current filesystem location.

Observed Result
/home/sidiqi
Why It Matters

Confirming the working directory helps prevent creating repositories,
scripts, Terraform state, or configuration files in unintended locations.

4. Verify Git
Command
git --version
Purpose

Verifies that Git is installed and displays the installed version.

Observed Result
git version 2.43.0
Usage in This Project

Git provides version control for:

Terraform
Scripts
Kubernetes manifests
CI/CD workflows
Documentation
Configuration
Application code
5. Verify GitHub CLI
Command
gh --version
Purpose

Verifies that GitHub CLI is installed.

Observed Result

GitHub CLI version 2.45.0 was installed during initial discovery.

Usage in This Project

GitHub CLI will be used to automate operations such as:

Repository management
Issue creation
Pull Request creation
Pull Request inspection
Workflow inspection
Project management
Repository configuration
6. Verify AWS CLI
Command
aws --version
Purpose

Verifies that AWS CLI is installed.

Observed Result
aws-cli/2.36.41
Usage in This Project

AWS CLI will be used for:

Identity validation
Infrastructure inspection
Resource validation
Troubleshooting
Operational tasks
Automation
Comparing Terraform configuration with deployed resources
7. Verify Terraform
Command
terraform version
Purpose

Displays the installed Terraform version and platform.

Observed Result
Terraform v1.16.1
on linux_amd64

Terraform also reported that a newer patch release was available at the
time of discovery.

Engineering Decision

The tool was not upgraded during environment discovery.

Tool upgrades should be intentional, tested, documented, and preferably
tracked through a separate GitHub Issue rather than performed as an
unrelated change.

8. Inspect Home Directory
Commands
cd ~
ls -la
Purpose

Inspects the user's home directory before creating the new repository.

Relevant Findings

Existing lab directories were present, including:

sidiqi-aws-cybersecurity-lab
sidiqi-aws-cybersecurity-lab.wiki
sidiqi-devops-k8s-lab

The new repository did not yet exist during initial discovery.

Security Observation

The home directory also contained authentication and configuration
locations such as:

.aws/
.kube/
.ssh/
.config/

These directories must not be copied into the project repository.

A PEM private-key file was also present in the home directory.

Private-key contents must never be committed to Git or copied into
project documentation.

9. Verify GitHub Authentication
Command
gh auth status
Purpose

Checks whether GitHub CLI has an authenticated GitHub session.

Observed Result

GitHub CLI reported an authenticated session for:

sidiqi-lab

The configured Git transport was HTTPS.

Security Requirement

gh auth status may display a masked representation of an authentication
token.

Authentication tokens must never be copied into repository
documentation, logs intended for publication, screenshots, Issues, or
Pull Requests.

10. Inspect Personal Repositories
Command
gh repo list --limit 100
Purpose

Lists repositories associated with the authenticated account under the
command's current context.

Observed Result

No repositories were returned directly under the authenticated personal
account during initial discovery.

Further organization membership inspection identified the organization
used for the lab repositories.

11. Identify GitHub User
Command
gh api user --jq '.login'
Purpose

Retrieves the login name of the authenticated GitHub account through the
GitHub API.

Observed Result
sidiqi-lab
12. Inspect Organization Membership
Command
gh api user/memberships/orgs \
  --jq '.[] | [.organization.login, .role, .state] | @tsv'
Purpose

Displays GitHub organization memberships together with role and
membership state.

Observed Result
sidiqi-lab-01    admin    active
Project Decision

The AWS Enterprise Cloud Lab repository was therefore created under:

sidiqi-lab-01
Security Lessons

Environment discovery can expose sensitive information.

Never publish:

Authentication tokens
AWS credentials
Private keys
Passwords
Session tokens
Sensitive kubeconfig data
Terraform secrets
Application secrets

Command output must be reviewed before it is added to documentation.

Validation Outcome

The environment contained the core tooling required to begin the project:

Git
GitHub CLI
AWS CLI
Terraform

GitHub authentication and organization membership were also successfully
validated.

The environment was therefore considered ready for repository bootstrap.

---

# 13. Check for ShellCheck

## Command

```bash
command -v shellcheck || echo "ShellCheck is not currently installed"
Purpose

Determines whether ShellCheck is available in the local engineering
environment.

Observed Result
ShellCheck is not currently installed
Engineering Decision

ShellCheck was not installed manually during Issue #1.

Instead, ShellCheck was incorporated into Pull Request validation so the
project can verify shell scripts automatically in CI.

A reusable bootstrap mechanism for local development dependencies will
be implemented separately.

Lesson

Dependency discovery and dependency installation are separate concerns.

Missing tooling should not automatically trigger undocumented manual
installation.

# ShellCheck SC2155 in Repository Validation Script

## Problem

Pull Request #2 failed the GitHub Actions ShellCheck job.

The Repository Validation job passed, but ShellCheck failed while
analyzing `scripts/validation/validate-repository.sh`.

## Symptoms

GitHub Actions reported:

```text
In scripts/validation/validate-repository.sh line 5:

readonly SCRIPT_NAME="$(basename "$0")"

SC2155 (warning): Declare and assign separately to avoid masking return values.
The ShellCheck job exited unsuccessfully.

Diagnostic Commands

The failed workflow was identified with:

gh run list \
  --repo sidiqi-lab-01/sidiqi-aws-enterprise-cloud-lab \
  --branch feature/1-project-engineering-workflow \
  --limit 5

The failed logs were retrieved with:

gh run view 34983923270 \
  --repo sidiqi-lab-01/sidiqi-aws-enterprise-cloud-lab \
  --log-failed
Root Cause

The script declared a readonly variable and executed command
substitution in the same statement:

readonly SCRIPT_NAME="$(basename "$0")"

ShellCheck SC2155 warns that declaration commands can mask the return
status of command substitutions.

Resolution

Separate assignment from the readonly declaration:

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
Validation

Validate Bash syntax:

bash -n scripts/validation/validate-repository.sh

Run repository validation:

./scripts/validation/validate-repository.sh

Check Git whitespace:

git diff --check
git diff --cached --check

After the correction is pushed, GitHub Actions must rerun ShellCheck
and pass before the Pull Request is eligible for merge.

Prevention

All reusable Bash scripts should be checked with ShellCheck in CI.

ShellCheck findings should be investigated rather than suppressed
unless there is a documented engineering reason for suppression.

CI validation supplements local validation and human review.

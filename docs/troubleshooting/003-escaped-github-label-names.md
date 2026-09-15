# Troubleshooting: Escaped GitHub Label Names

## Problem

GitHub project-management configuration accidentally defined label names containing literal backslashes before colons.

Examples:

```text
priority\:P0
type\:security
domain\:networking
iac\:terraform
The intended label names were:

priority:P0
type:security
domain:networking
iac:terraform
Symptoms

The malformed names appeared in:

config/github/labels.tsv
config/github/issues.tsv
GitHub repository labels created by automation

Structural TSV validation did not detect the problem because the affected rows still contained the expected number of tab-separated fields.

Root Cause

Backslashes were unnecessarily inserted before colons while constructing configuration data.

Because the configuration was written using a literal heredoc, the backslashes were preserved as actual characters.

The label automation then correctly processed the configured strings, which caused GitHub labels to be created with the malformed names.

Resolution

Normalized the desired-state configuration by replacing:

\:

with:

:

The malformed GitHub labels were renamed in place to their intended names.

The label automation was then rerun to reconcile label metadata against the corrected configuration.

Validation

Validation confirmed:

no escaped label names remained in configuration
all issue-required labels existed in labels.tsv
all configured managed labels existed in GitHub
the repository contained 29 managed project labels
the repository retained its standard GitHub labels
label automation remained idempotent
Prevention

Project configuration validation must reject unexpected backslashes in controlled configuration values.

Validation must verify semantic content in addition to TSV column counts.

Issue label references must be cross-checked against configured labels before issue creation.

Configured labels must also be cross-checked against the actual GitHub repository state before project population.

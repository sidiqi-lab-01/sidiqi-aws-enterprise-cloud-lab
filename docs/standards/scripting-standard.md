# Reusable Scripting Standard

## Purpose

This document defines standards for reusable project automation.

## Automation Principle

When a procedure is repeated or is prone to manual error, it should be
evaluated for automation.

Automation should improve:

- Repeatability
- Reliability
- Security
- Consistency
- Troubleshooting
- Operational efficiency

## Bash Standard

Bash scripts should normally begin with:

```bash
#!/usr/bin/env bash

set -Eeuo pipefail
Required Characteristics

Reusable scripts should provide applicable features such as:

Input validation
Dependency validation
Meaningful error messages
Meaningful exit codes
Safe defaults
Logging
Help output
Idempotent behavior where practical
Environment-independent configuration where practical
Clear documentation
Configuration

Prefer configuration through:

Command-line arguments
Environment variables
Configuration files
Terraform variables

Avoid hard-coded environment-specific values where practical.

Credentials

Credentials must never be hard-coded into scripts.

Use approved credential mechanisms such as:

IAM roles
AWS credential providers
GitHub secrets
AWS Secrets Manager
AWS Systems Manager Parameter Store
Kubernetes Secrets where appropriate
Script Organization
scripts/
├── bootstrap/
├── git/
├── validation/
├── aws/
├── terraform/
├── kubernetes/
└── security/

Additional categories may be introduced as the project grows.

Exit Codes

Convention:

0 = success
non-zero = failure

Scripts used by CI/CD must return reliable exit codes so workflows can
determine whether validation succeeded.

Logging

Messages should make it clear:

What operation is running
What was validated
What failed
What the operator should investigate

Secrets must not be printed to logs.

Destructive Operations

Scripts performing destructive actions must include safeguards where
appropriate.

Examples include:

Confirmation
Explicit environment selection
Resource validation
Dry-run support
Clear warning messages
Validation

Scripts should be checked with tools such as ShellCheck when available.

Example:

shellcheck scripts/example.sh
Documentation

Each reusable script should document:

Purpose
Usage
Arguments
Dependencies
Examples
Exit behavior
Security considerations

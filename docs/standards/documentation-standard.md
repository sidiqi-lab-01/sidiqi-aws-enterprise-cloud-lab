# Documentation Standard

## Purpose

Documentation is treated as part of the implementation rather than an
after-the-fact activity.

## Required Documentation

Significant features should document applicable areas including:

1. Objective
2. Requirements
3. Architecture
4. Design decisions
5. Prerequisites
6. Implementation
7. Commands
8. Reusable automation
9. Configuration
10. Validation
11. Security
12. Cost considerations
13. Monitoring
14. Troubleshooting
15. Rollback
16. Cleanup
17. Lessons learned

## Command Documentation

Commands should document:

- Purpose
- Syntax
- Parameters
- Prerequisites
- Expected result
- Actual result when useful
- Validation
- Security considerations
- Common errors
- Troubleshooting

## Troubleshooting Documentation

Useful failures should be preserved as engineering knowledge:

```text
Problem
  ↓
Symptoms
  ↓
Diagnostic commands
  ↓
Evidence
  ↓
Root cause
  ↓
Resolution
  ↓
Validation
  ↓
Prevention
Sensitive Information

Documentation must not expose:

Credentials
Authentication tokens
Private keys
Passwords
Sensitive account information
Secrets
Sensitive Terraform outputs
Sensitive kubeconfig contents

Example output should be sanitized when required.

Documentation Location

Documentation is organized under:

docs/
├── ai/
├── architecture/
├── cicd/
├── commands/
├── runbooks/
├── security/
├── standards/
├── troubleshooting/
└── workflows/
Documentation Review

Documentation changes are reviewed through the same Pull Request process
as infrastructure and application changes.

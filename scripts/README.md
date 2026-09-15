# Project Automation Scripts

Reusable project automation is maintained under this directory.

## Structure

```text
scripts/
├── bootstrap/
├── git/
└── validation/
Additional categories will be introduced as required.

Repository Validation

Run:

./scripts/validation/validate-repository.sh

The repository validation script currently checks:

Git repository context
Current branch
Git whitespace errors
Potential sensitive file types
Required project documentation

The same validation logic is intended to be reused by local development
and CI/CD.

Security

Scripts must not contain embedded credentials, tokens, passwords, or
private keys.

See:

docs/standards/scripting-standard.md

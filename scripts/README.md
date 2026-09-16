# Project Automation Scripts

Reusable project automation is maintained under this directory.

## Structure

```text
scripts/
├── bootstrap/
├── git/
├── terraform/
└── validation/
```

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

## Terraform

### Initialize the lab backend

Purpose

Initialize the Terraform backend for `terraform/environments/lab` by reading
the bootstrap backend state bucket from `terraform/bootstrap/backend`.

Usage

```bash
./scripts/terraform/init-lab.sh
```

Arguments

This command does not accept positional arguments.

Dependencies

- `terraform` must be installed and available on `PATH`
- `terraform/bootstrap/backend` must already be initialized and applied so the
  `state_bucket_name` output exists
- AWS credentials must permit reading the bootstrap backend state and
  initializing the lab backend
- Set `bootstrap_role_arn` in the lab Terraform inputs before planning or
  applying the lab environment

Examples

```bash
./scripts/terraform/init-lab.sh
terraform -chdir=terraform/environments/lab plan \
  -var='bootstrap_role_arn=arn:aws:iam::123456789012:role/sidiqi-bootstrap-terraform'
```

Exit behavior

Returns `0` on success and a non-zero exit code if Terraform is unavailable,
the bootstrap backend output is missing, or `terraform init` fails.

Security considerations

Do not commit account-specific backend values or credentials. Provide AWS
access through approved credential providers, and verify that
`bootstrap_role_arn` references the intended bootstrap role in the current AWS
account.

# Terraform Lab Workflow

This document describes the operator workflow for bootstrapping and initializing
the Terraform lab environment.

## 1. Purpose

The Terraform workflow provides a repeatable method for:

- Creating the remote Terraform state backend.
- Obtaining the backend bucket name from Terraform output.
- Initializing the lab environment against the remote backend.
- Supplying the authorized bootstrap IAM role.
- Validating Terraform configuration.
- Planning infrastructure changes.
- Handling backend configuration changes safely.

The workflow intentionally avoids hardcoding account-specific identifiers,
credentials, or the generated S3 state bucket name in repository files.

## 2. Prerequisites

Before running the workflow:

- Terraform must be installed.
- AWS CLI authentication must already be available through an approved identity.
- The AWS region must be `us-east-1`.
- The operator must have permission to create or access the required AWS resources.
- The repository must be checked out locally.
- Long-lived AWS credentials must not be stored in the repository.

Verify the active AWS identity:

```bash
aws sts get-caller-identity
Verify the configured region:

aws configure get region

Expected region:

us-east-1
3. Bootstrap the Terraform Backend

The backend bootstrap configuration is located at:

terraform/bootstrap/backend

Initialize it:

terraform -chdir=terraform/bootstrap/backend init

Validate it:

terraform -chdir=terraform/bootstrap/backend validate

Review the proposed infrastructure:

terraform -chdir=terraform/bootstrap/backend plan

Create the backend resources only after reviewing the plan:

terraform -chdir=terraform/bootstrap/backend apply

The backend creates an S3 state bucket with security controls including
versioning, server-side encryption, public-access blocking, and a TLS-only
bucket policy.

The backend bootstrap state remains local because it manages the remote-state
bucket itself. Do not commit its Terraform state to Git.

4. Obtain the State Bucket

The generated state bucket name is obtained from the backend bootstrap output:

terraform -chdir=terraform/bootstrap/backend output -raw state_bucket_name

The bucket name is intentionally not hardcoded in the lab Terraform
configuration.

5. Initialize the Lab Backend

Use the repository helper:

./scripts/terraform/init-lab.sh

The script:

Verifies Terraform is installed.
Verifies the backend bootstrap state exists.
Reads the generated state bucket from the bootstrap Terraform output.
Initializes terraform/environments/lab using that bucket.

Expected completion message:

Lab Terraform backend initialized successfully.

The script intentionally does not automatically use terraform init -reconfigure. If Terraform detects a backend configuration change, stop and
determine whether state migration or deliberate backend reconfiguration is
required before continuing.

This prevents silently repointing the environment to a different backend
without considering existing Terraform state.

6. Identify the Authorized Bootstrap Role

Obtain the current caller ARN:

aws sts get-caller-identity --query Arn --output text

For this lab, the trusted principal supplied to Terraform must be an IAM role
ARN in the same AWS account as the deployment role.

Set the role ARN for the current shell:

export BOOTSTRAP_ROLE_ARN="<authorized-bootstrap-role-arn>"

Do not place account-specific role ARNs or temporary credentials in committed
repository files.

7. Validate the Lab Configuration

Format Terraform files:

terraform fmt -recursive terraform/

Validate the lab environment:

terraform -chdir=terraform/environments/lab validate

Expected result:

Success! The configuration is valid.
8. Plan the Lab Environment

Run:

terraform -chdir=terraform/environments/lab plan \
  -var="bootstrap_role_arn=${BOOTSTRAP_ROLE_ARN}"

When the deployed infrastructure already matches the configuration, the
expected result is:

No changes. Your infrastructure matches the configuration.

Always review the plan before applying changes.

9. IAM Trust-Boundary Validation

The reusable IAM module validates that the trusted bootstrap principal:

Uses IAM role ARN syntax.
Belongs to the expected AWS account.

A role ARN from another account must cause Terraform planning to fail with a
resource precondition error rather than merely producing a warning.

This validation protects the deployment-role trust policy from unintended
cross-account configuration.

10. Backend Failure Handling

If init-lab.sh reports that backend bootstrap state is missing, do not create
an arbitrary replacement bucket or hardcode a bucket name.

Verify that the backend bootstrap was completed from the expected working
environment and that its local state is available.

If Terraform reports that the backend configuration changed, review the
existing state location before choosing a recovery action.

Use explicit Terraform backend migration or reconfiguration commands only after
confirming the intended state location. The helper script deliberately leaves
that decision to the operator.

11. Security Considerations

Never commit:

terraform.tfstate
Terraform state backups
.terraform/
Terraform plan artifacts
AWS access keys
AWS secret keys
AWS session tokens
Private keys
Account-specific secrets

Temporary role credentials should be allowed to expire naturally or removed
from the shell environment after testing.

12. Validation Checklist

Before committing Terraform changes, verify:

terraform fmt -recursive terraform/
terraform -chdir=terraform/environments/lab validate
bash -n scripts/terraform/init-lab.sh
./scripts/github/validate-project-config.sh
git diff --check

For IAM changes, also perform the appropriate positive and negative
authorization tests and document sanitized results in the issue or pull
request.

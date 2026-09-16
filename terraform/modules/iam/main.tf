data "aws_iam_policy_document" "terraform_deployment_trust" {
  statement {
    sid     = "AllowBootstrapRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn]
    }
  }
}

resource "aws_iam_role" "terraform_deployment" {
  name = "${var.project_name}-${var.environment}-terraform-deployment-role"

  description = "Terraform deployment role for the AWS Enterprise Cloud Lab."

  assume_role_policy   = data.aws_iam_policy_document.terraform_deployment_trust.json
  max_session_duration = 3600

  tags = {
    Purpose = "TerraformDeployment"
  }

  lifecycle {
    precondition {
      condition = (
        split(":", var.trusted_role_arn)[4] ==
        var.expected_account_id
      )

      error_message = "trusted_role_arn must belong to the expected AWS account."
    }
  }
}

data "aws_iam_policy_document" "administrative_trust" {
  statement {
    sid     = "AllowBootstrapRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn]
    }
  }
}

resource "aws_iam_role" "administrative" {
  name        = "${var.project_name}-${var.environment}-administrative-role"
  description = "Controlled administrative privilege-elevation role for the AWS Enterprise Cloud Lab."

  assume_role_policy   = data.aws_iam_policy_document.administrative_trust.json
  max_session_duration = 3600

  tags = {
    Purpose = "AdministrativeAccess"
  }

  lifecycle {
    precondition {
      condition = (
        split(":", var.trusted_role_arn)[4] ==
        var.expected_account_id
      )

      error_message = "trusted_role_arn must belong to the expected AWS account."
    }
  }
}

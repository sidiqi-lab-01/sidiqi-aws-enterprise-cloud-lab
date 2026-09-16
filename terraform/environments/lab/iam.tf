data "aws_caller_identity" "current" {}

resource "terraform_data" "bootstrap_role_validation" {
  input = var.bootstrap_role_arn

  lifecycle {
    precondition {
      condition = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.bootstrap_role_arn)) && split(":", var.bootstrap_role_arn)[4] == data.aws_caller_identity.current.account_id
      error_message = "bootstrap_role_arn must be a valid IAM role ARN in the current AWS account."
    }
  }
}

module "iam" {
  source = "../../modules/iam"

  project_name     = var.project_name
  environment      = var.environment
  trusted_role_arn = var.bootstrap_role_arn

  depends_on = [terraform_data.bootstrap_role_validation]
}

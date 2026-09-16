data "aws_caller_identity" "current" {}

resource "terraform_data" "bootstrap_role_validation" {
  input = var.bootstrap_role_arn

  lifecycle {
    precondition {
      condition = can(split(":", var.bootstrap_role_arn)[4]) && split(":", var.bootstrap_role_arn)[4] == data.aws_caller_identity.current.account_id
      error_message = "bootstrap_role_arn must belong to an IAM role in the current AWS account."
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

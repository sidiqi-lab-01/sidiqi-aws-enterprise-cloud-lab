module "iam" {
  source = "../../modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  trusted_role_arn    = var.bootstrap_role_arn
  expected_account_id = data.aws_caller_identity.current.account_id
}

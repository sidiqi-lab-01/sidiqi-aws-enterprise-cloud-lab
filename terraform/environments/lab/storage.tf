module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  environment  = var.environment

  bucket_name = "sidiqi-${var.environment}-${data.aws_caller_identity.current.account_id}-app-data"

  noncurrent_version_expiration_days = 30
}

module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  environment  = var.environment
  bucket_name  = "sidiqi-${var.environment}-${data.aws_caller_identity.current.account_id}-app-data"

  noncurrent_version_expiration_days = 30

  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  application_security_group_id = module.network.application_security_group_id
}

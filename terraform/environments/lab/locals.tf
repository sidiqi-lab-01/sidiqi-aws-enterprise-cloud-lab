locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "sidiqi-aws-enterprise-cloud-lab"
  }
}

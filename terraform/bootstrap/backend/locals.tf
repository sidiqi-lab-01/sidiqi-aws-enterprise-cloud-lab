locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "TerraformState"
    Repository  = "sidiqi-aws-enterprise-cloud-lab"
  }
}

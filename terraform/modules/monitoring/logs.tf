resource "aws_cloudwatch_log_group" "system" {
  name              = "/${var.project_name}/${var.environment}/system"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${local.name_prefix}-system-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Observability"
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${local.name_prefix}-application-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Observability"
  }
}

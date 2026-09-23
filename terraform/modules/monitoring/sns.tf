resource "aws_sns_topic" "monitoring" {
  name = "${local.name_prefix}-monitoring-alerts"

  tags = {
    Name        = "${local.name_prefix}-monitoring-alerts"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "MonitoringAlerts"
  }
}

resource "aws_sns_topic" "monitoring" {
  name = "${local.name_prefix}-monitoring-alerts"

  tags = {
    Name        = "${local.name_prefix}-monitoring-alerts"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "MonitoringAlerts"
  }
}

resource "aws_sns_topic_subscription" "monitoring_email" {
  count = var.alert_email != null ? 1 : 0

  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_subscription" "monitoring_sms" {
  count = var.alert_phone_number != null ? 1 : 0

  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "sms"
  endpoint  = var.alert_phone_number
}

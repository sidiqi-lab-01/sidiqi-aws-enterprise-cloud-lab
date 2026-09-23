output "sns_topic_arn" {
  description = "SNS topic used for CloudWatch alarm notifications."
  value       = aws_sns_topic.monitoring.arn
}

output "system_log_group_name" {
  description = "CloudWatch system log group."
  value       = aws_cloudwatch_log_group.system.name
}

output "application_log_group_name" {
  description = "CloudWatch application log group."
  value       = aws_cloudwatch_log_group.application.name
}

output "cloudwatch_agent_parameter_name" {
  description = "SSM Parameter containing the CloudWatch Agent configuration."
  value       = aws_ssm_parameter.cloudwatch_agent_config.name
}

output "cloudwatch_agent_configure_association_id" {
  description = "SSM association used to configure the CloudWatch Agent."
  value       = aws_ssm_association.cloudwatch_agent_configure.association_id
}

variable "project_name" {
  description = "Project name used for monitoring resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region containing the monitored resources."
  type        = string
}

variable "autoscaling_group_name" {
  description = "Application Auto Scaling Group name."
  type        = string
}

variable "load_balancer_arn" {
  description = "Application Load Balancer ARN."
  type        = string
}

variable "target_group_arn" {
  description = "Application target group ARN."
  type        = string
}

variable "db_instance_id" {
  description = "RDS database instance identifier."
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB application-state table name."
  type        = string
}

variable "vpc_flow_log_group_name" {
  description = "Existing CloudWatch Log Group for VPC Flow Logs."
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for monitoring log groups."
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address subscribed to CloudWatch monitoring alerts"
  type        = string
  default     = null
  nullable    = true
}

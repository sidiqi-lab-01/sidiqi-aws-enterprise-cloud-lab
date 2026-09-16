variable "aws_region" {
  description = "AWS region used for regional lab resources."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "The lab environment is standardized on us-east-1 (N. Virginia)."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "lab"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "sidiqi-aws-enterprise-cloud-lab"
}

variable "bootstrap_role_arn" {
  description = "ARN of the existing bootstrap IAM role permitted to assume the Terraform deployment role."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.bootstrap_role_arn))
    error_message = "bootstrap_role_arn must be a valid IAM role ARN."
  }
}

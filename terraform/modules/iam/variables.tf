variable "project_name" {
  description = "Project name used for IAM naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "trusted_role_arn" {
  description = "ARN of the existing bootstrap role permitted to assume the Terraform deployment role."
  type        = string
}

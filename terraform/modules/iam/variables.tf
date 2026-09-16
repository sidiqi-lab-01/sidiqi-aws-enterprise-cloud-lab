variable "project_name" {
  description = "Project name used for IAM naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "trusted_role_arn" {
  description = "ARN of the existing bootstrap IAM role permitted to assume the Terraform deployment role."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/[A-Za-z0-9+=,.@_/-]+$", var.trusted_role_arn))
    error_message = "trusted_role_arn must be an IAM role ARN."
  }
}

variable "expected_account_id" {
  description = "AWS account ID in which the trusted bootstrap IAM role must exist."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "expected_account_id must be a 12-digit AWS account ID."
  }
}

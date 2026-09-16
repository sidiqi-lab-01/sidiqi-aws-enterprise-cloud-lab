variable "aws_region" {
  description = "AWS region for the Terraform backend."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "The lab backend must be deployed in us-east-1."
  }
}

variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "sidiqi-aws-enterprise-cloud-lab"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "lab"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string
}

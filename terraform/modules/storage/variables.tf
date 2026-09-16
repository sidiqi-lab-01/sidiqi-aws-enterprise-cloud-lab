variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique name for the application data bucket."
  type        = string
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent object versions expire."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days > 0
    error_message = "Noncurrent version expiration must be greater than zero days."
  }
}

variable "vpc_id" {
  description = "ID of the VPC hosting the EFS mount targets."
  type        = string
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs used for EFS mount targets."
  type        = map(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for highly available EFS mount targets."
  }
}

variable "application_security_group_id" {
  description = "Security group ID of workloads permitted to access EFS."
  type        = string
}

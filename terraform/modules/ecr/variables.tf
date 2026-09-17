variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "image_retention_count" {
  description = "Maximum number of tagged release images retained."
  type        = number
  default     = 20

  validation {
    condition     = var.image_retention_count >= 1
    error_message = "image_retention_count must be at least 1."
  }
}

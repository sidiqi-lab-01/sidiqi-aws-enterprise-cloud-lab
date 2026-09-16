variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group."
  type        = map(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for the RDS DB subnet group."
  }
}

variable "database_security_group_id" {
  description = "Security group ID controlling access to the database."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version. Null allows AWS to select the current supported default."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS database instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial database storage allocation in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage allocation in GiB for RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
  default     = 7
}

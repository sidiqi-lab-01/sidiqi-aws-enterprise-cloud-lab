variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "instance_type" {
  description = "Default EC2 instance type for representative workloads."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the Auto Scaling Group."
  type        = list(string)
}

variable "application_security_group_id" {
  description = "Security group ID assigned to application instances."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile assigned to EC2 workloads."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN for application instances."
  type        = string
}

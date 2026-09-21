variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet configuration by Availability Zone."

  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  description = "Private subnet configuration by Availability Zone."

  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "public_domain_name" {
  description = "Public Route 53 domain for the application."
  type        = string
}

variable "application_domain_name" {
  description = "Public fully qualified domain name for the application."
  type        = string
}

output "terraform_deployment_role_name" {
  description = "Name of the Terraform deployment role."
  value       = module.iam.terraform_deployment_role_name
}

output "terraform_deployment_role_arn" {
  description = "ARN of the Terraform deployment role."
  value       = module.iam.terraform_deployment_role_arn
}

output "terraform_deployment_policy_name" {
  description = "Name of the Terraform deployment policy."
  value       = module.iam.terraform_deployment_policy_name
}

output "terraform_deployment_policy_arn" {
  description = "ARN of the Terraform deployment policy."
  value       = module.iam.terraform_deployment_policy_arn
}

output "administrative_role_name" {
  description = "Name of the controlled administrative role."
  value       = module.iam.administrative_role_name
}

output "administrative_role_arn" {
  description = "ARN of the controlled administrative role."
  value       = module.iam.administrative_role_arn
}

output "ec2_workload_role_name" {
  description = "Name of the EC2 workload IAM role."
  value       = module.iam.ec2_workload_role_name
}

output "ec2_workload_role_arn" {
  description = "ARN of the EC2 workload IAM role."
  value       = module.iam.ec2_workload_role_arn
}

output "ec2_workload_instance_profile_name" {
  description = "Name of the EC2 workload instance profile."
  value       = module.iam.ec2_workload_instance_profile_name
}

output "vpc_id" {
  description = "ID of the lab VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the lab VPC."
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the lab Internet Gateway."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the lab NAT Gateway."
  value       = module.network.nat_gateway_id
}

output "public_route_table_id" {
  description = "ID of the lab public route table."
  value       = module.network.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the lab private route table."
  value       = module.network.private_route_table_id
}

output "alb_security_group_id" {
  description = "ID of the lab ALB security group."
  value       = module.network.alb_security_group_id
}

output "application_security_group_id" {
  description = "ID of the lab application security group."
  value       = module.network.application_security_group_id
}

output "database_security_group_id" {
  description = "ID of the lab database security group."
  value       = module.network.database_security_group_id
}

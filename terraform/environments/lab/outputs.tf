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

output "s3_vpc_endpoint_id" {
  description = "ID of the lab S3 Gateway VPC endpoint."
  value       = module.network.s3_vpc_endpoint_id
}

output "ssm_vpc_endpoint_id" {
  description = "ID of the lab SSM interface VPC endpoint."
  value       = module.network.ssm_vpc_endpoint_id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "ID of the lab SSM Messages interface VPC endpoint."
  value       = module.network.ssm_messages_vpc_endpoint_id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "ID of the lab EC2 Messages interface VPC endpoint."
  value       = module.network.ec2_messages_vpc_endpoint_id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the lab VPC endpoints security group."
  value       = module.network.vpc_endpoints_security_group_id
}

output "private_hosted_zone_id" {
  description = "ID of the lab Route 53 private hosted zone."
  value       = module.network.private_hosted_zone_id
}

output "private_hosted_zone_name" {
  description = "Name of the lab Route 53 private hosted zone."
  value       = module.network.private_hosted_zone_name
}

output "application_load_balancer_arn" {
  description = "ARN of the lab application load balancer."
  value       = module.network.application_load_balancer_arn
}

output "application_load_balancer_dns_name" {
  description = "DNS name of the lab application load balancer."
  value       = module.network.application_load_balancer_dns_name
}

output "application_load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the lab application load balancer."
  value       = module.network.application_load_balancer_zone_id
}

output "application_target_group_arn" {
  description = "ARN of the lab application target group."
  value       = module.network.application_target_group_arn
}

output "vpc_flow_log_id" {
  description = "ID of the lab VPC Flow Log."
  value       = module.network.vpc_flow_log_id
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch Log Group receiving lab VPC Flow Logs."
  value       = module.network.vpc_flow_log_group_name
}

output "vpc_flow_log_role_arn" {
  description = "ARN of the IAM role used by lab VPC Flow Logs."
  value       = module.network.vpc_flow_log_role_arn
}

output "ec2_baseline_ami_id" {
  description = "Amazon Linux 2023 AMI selected for the secure EC2 baseline."
  value       = module.compute.ami_id
}

output "ec2_baseline_instance_type" {
  description = "Default instance type for the secure EC2 baseline."
  value       = module.compute.instance_type
}

output "ec2_baseline_metadata_options" {
  description = "IMDS security settings for the secure EC2 baseline."
  value       = module.compute.metadata_options
}

output "ec2_baseline_root_block_device" {
  description = "Root EBS security configuration for the secure EC2 baseline."
  value       = module.compute.root_block_device
}

output "ec2_baseline_monitoring_enabled" {
  description = "Whether detailed monitoring is enabled for the EC2 baseline."
  value       = module.compute.monitoring_enabled
}

output "application_launch_template_id" {
  description = "ID of the lab application EC2 Launch Template."
  value       = module.compute.launch_template_id
}

output "application_autoscaling_group_name" {
  description = "Name of the lab application Auto Scaling Group."
  value       = module.compute.autoscaling_group_name
}

output "application_data_bucket_id" {
  description = "ID of the application data S3 bucket."
  value       = module.storage.bucket_id
}

output "application_data_bucket_arn" {
  description = "ARN of the application data S3 bucket."
  value       = module.storage.bucket_arn
}

output "application_data_bucket_domain_name" {
  description = "Domain name of the application data S3 bucket."
  value       = module.storage.bucket_domain_name
}

output "efs_file_system_id" {
  description = "ID of the shared EFS file system."
  value       = module.storage.efs_file_system_id
}

output "efs_dns_name" {
  description = "DNS name of the shared EFS file system."
  value       = module.storage.efs_dns_name
}

output "efs_security_group_id" {
  description = "ID of the EFS security group."
  value       = module.storage.efs_security_group_id
}

output "efs_mount_target_ids" {
  description = "Map of EFS mount target IDs by private subnet."
  value       = module.storage.efs_mount_target_ids
}

output "db_instance_id" {
  description = "RDS PostgreSQL DB instance identifier."
  value       = module.database.db_instance_id
}

output "db_instance_arn" {
  description = "ARN of the RDS PostgreSQL DB instance."
  value       = module.database.db_instance_arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL connection endpoint."
  value       = module.database.db_endpoint
}

output "db_port" {
  description = "RDS PostgreSQL connection port."
  value       = module.database.db_port
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = module.database.db_subnet_group_name
}

output "db_master_user_secret_arn" {
  description = "ARN of the AWS-managed RDS master-user secret."
  value       = module.database.master_user_secret_arn
}

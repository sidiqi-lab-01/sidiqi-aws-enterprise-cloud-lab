output "ami_id" {
  description = "Amazon Linux 2023 AMI ID selected for the EC2 baseline."
  value       = nonsensitive(local.ec2_baseline.ami_id)
}

output "instance_type" {
  description = "Default EC2 instance type for the secure baseline."
  value       = local.ec2_baseline.instance_type
}

output "associate_public_ip_address" {
  description = "Whether baseline workloads receive public IPv4 addresses."
  value       = local.ec2_baseline.associate_public_ip_address
}

output "metadata_options" {
  description = "EC2 Instance Metadata Service security configuration."
  value       = local.ec2_baseline.metadata_options
}

output "root_block_device" {
  description = "Secure root EBS configuration."
  value       = local.ec2_baseline.root_block_device
}

output "monitoring_enabled" {
  description = "Whether detailed EC2 monitoring is enabled."
  value       = local.ec2_baseline.monitoring
}

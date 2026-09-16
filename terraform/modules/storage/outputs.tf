output "bucket_id" {
  description = "ID of the application data bucket."
  value       = aws_s3_bucket.application_data.id
}

output "bucket_arn" {
  description = "ARN of the application data bucket."
  value       = aws_s3_bucket.application_data.arn
}

output "bucket_domain_name" {
  description = "Domain name of the application data bucket."
  value       = aws_s3_bucket.application_data.bucket_domain_name
}

output "efs_file_system_id" {
  description = "ID of the shared EFS file system."
  value       = aws_efs_file_system.shared.id
}

output "efs_dns_name" {
  description = "DNS name of the shared EFS file system."
  value       = aws_efs_file_system.shared.dns_name
}

output "efs_security_group_id" {
  description = "ID of the EFS security group."
  value       = aws_security_group.efs.id
}

output "efs_mount_target_ids" {
  description = "Map of EFS mount target IDs by private subnet key."
  value = {
    for key, target in aws_efs_mount_target.shared : key => target.id
  }
}

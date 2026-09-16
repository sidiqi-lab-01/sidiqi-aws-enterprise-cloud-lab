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

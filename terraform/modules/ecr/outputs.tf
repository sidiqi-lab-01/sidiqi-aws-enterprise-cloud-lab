output "repository_name" {
  description = "Name of the ECR application repository."
  value       = aws_ecr_repository.application.name
}

output "repository_arn" {
  description = "ARN of the ECR application repository."
  value       = aws_ecr_repository.application.arn
}

output "repository_url" {
  description = "URL of the ECR application repository."
  value       = aws_ecr_repository.application.repository_url
}

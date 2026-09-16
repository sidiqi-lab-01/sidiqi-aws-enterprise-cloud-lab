output "terraform_deployment_role_name" {
  description = "Name of the Terraform deployment role."
  value       = aws_iam_role.terraform_deployment.name
}

output "terraform_deployment_role_arn" {
  description = "ARN of the Terraform deployment role."
  value       = aws_iam_role.terraform_deployment.arn
}

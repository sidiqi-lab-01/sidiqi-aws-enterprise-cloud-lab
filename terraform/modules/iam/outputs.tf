output "terraform_deployment_role_name" {
  description = "Name of the Terraform deployment role."
  value       = aws_iam_role.terraform_deployment.name
}

output "terraform_deployment_role_arn" {
  description = "ARN of the Terraform deployment role."
  value       = aws_iam_role.terraform_deployment.arn
}

output "terraform_deployment_policy_name" {
  description = "Name of the Terraform deployment policy."
  value       = aws_iam_policy.terraform_deployment.name
}

output "terraform_deployment_policy_arn" {
  description = "ARN of the Terraform deployment policy."
  value       = aws_iam_policy.terraform_deployment.arn
}

output "administrative_role_name" {
  description = "Name of the controlled administrative role."
  value       = aws_iam_role.administrative.name
}

output "administrative_role_arn" {
  description = "ARN of the controlled administrative role."
  value       = aws_iam_role.administrative.arn
}

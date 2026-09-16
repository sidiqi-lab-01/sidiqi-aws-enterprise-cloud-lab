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

output "ec2_workload_role_name" {
  description = "Name of the EC2 workload IAM role."
  value       = aws_iam_role.ec2_workload.name
}

output "ec2_workload_role_arn" {
  description = "ARN of the EC2 workload IAM role."
  value       = aws_iam_role.ec2_workload.arn
}

output "ec2_workload_instance_profile_name" {
  description = "Name of the EC2 workload instance profile."
  value       = aws_iam_instance_profile.ec2_workload.name
}

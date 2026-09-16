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

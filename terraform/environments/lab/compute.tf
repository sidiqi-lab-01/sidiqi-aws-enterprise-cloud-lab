module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  environment  = var.environment

  instance_type    = "t3.micro"
  root_volume_size = 20

  private_subnet_ids = [
    module.network.private_subnet_ids["1a"],
    module.network.private_subnet_ids["1b"],
  ]

  application_security_group_id = module.network.application_security_group_id
  instance_profile_name         = module.iam.ec2_workload_instance_profile_name
  target_group_arn              = module.network.application_target_group_arn
}

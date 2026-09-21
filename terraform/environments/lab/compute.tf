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

  application_image   = "785823823915.dkr.ecr.us-east-1.amazonaws.com/sidiqi-aws-enterprise-cloud-lab-lab-application@sha256:989be90502e17814bf91057d4044258ee252801ae6a96a03fe8dfad4bd9a55e9"
  application_version = "web-334c28c"
}

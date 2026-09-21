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

  application_image   = "785823823915.dkr.ecr.us-east-1.amazonaws.com/sidiqi-aws-enterprise-cloud-lab-lab-application@sha256:fd7f50cafdedd4f82a3312b33d14a809a5d75524fcd1e8015033582ea9a9c74f"
  application_version = "web-0451fda"
}

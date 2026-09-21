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

  application_image   = "785823823915.dkr.ecr.us-east-1.amazonaws.com/sidiqi-aws-enterprise-cloud-lab-lab-application@sha256:b97edf2c464a238e8edd6e621a9b452818377722686896db7c31229b09f183da"
  application_version = "web-946545a"
}

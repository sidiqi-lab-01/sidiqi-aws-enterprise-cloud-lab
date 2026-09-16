module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  environment  = var.environment

  instance_type    = "t3.micro"
  root_volume_size = 20
}

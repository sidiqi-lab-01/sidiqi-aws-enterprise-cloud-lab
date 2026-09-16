module "database" {
  source = "../../modules/database"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids         = module.network.private_subnet_ids
  database_security_group_id = module.network.database_security_group_id

  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  backup_retention_period = 1
}

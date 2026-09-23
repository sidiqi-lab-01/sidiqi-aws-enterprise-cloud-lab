module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = "us-east-1"

  autoscaling_group_name = module.compute.autoscaling_group_name

  load_balancer_arn = module.network.application_load_balancer_arn
  target_group_arn  = module.network.application_target_group_arn

  db_instance_id = module.database.db_instance_id

  dynamodb_table_name = module.database.dynamodb_table_name

  vpc_flow_log_group_name = module.network.vpc_flow_log_group_name

  log_retention_days = 30
  alert_email        = var.alert_email
  alert_phone_number = var.alert_phone_number
}

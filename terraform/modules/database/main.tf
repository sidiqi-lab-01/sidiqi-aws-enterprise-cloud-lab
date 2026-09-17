resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Tier        = "Database"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "postgresql" {
  identifier = "${var.project_name}-${var.environment}-postgresql"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "application"
  username = "dbadmin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  multi_az = var.multi_az

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring.arn : null

  deletion_protection = false
  skip_final_snapshot = true

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]

  copy_tags_to_snapshot = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgresql"
    Environment = var.environment
    Tier        = "Database"
    Purpose     = "ManagedRelationalDatabase"
    ManagedBy   = "Terraform"
  }
}

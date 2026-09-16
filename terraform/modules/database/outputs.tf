output "db_instance_id" {
  description = "RDS PostgreSQL DB instance identifier."
  value       = aws_db_instance.postgresql.id
}

output "db_instance_arn" {
  description = "ARN of the RDS PostgreSQL DB instance."
  value       = aws_db_instance.postgresql.arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL connection endpoint."
  value       = aws_db_instance.postgresql.address
}

output "db_port" {
  description = "RDS PostgreSQL connection port."
  value       = aws_db_instance.postgresql.port
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "master_user_secret_arn" {
  description = "ARN of the AWS-managed Secrets Manager master credential."
  value       = aws_db_instance.postgresql.master_user_secret[0].secret_arn
}

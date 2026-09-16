resource "aws_security_group" "efs" {
  name        = "${var.project_name}-${var.environment}-efs-sg"
  description = "Security group for shared EFS storage."
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-efs-sg"
    Environment = var.environment
    Tier        = "Storage"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_from_application" {
  security_group_id = aws_security_group.efs.id

  description                  = "Allow NFS from application workloads."
  referenced_security_group_id = var.application_security_group_id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "efs" {
  security_group_id = aws_security_group.efs.id

  description = "Allow return traffic from EFS mount targets."
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_efs_file_system" "shared" {
  creation_token = "${var.project_name}-${var.environment}-shared-efs"

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-shared-efs"
    Environment = var.environment
    Purpose     = "SharedApplicationStorage"
    ManagedBy   = "Terraform"
  }
}

resource "aws_efs_mount_target" "shared" {
  for_each = var.private_subnet_ids

  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

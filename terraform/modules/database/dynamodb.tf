resource "aws_dynamodb_table" "application_state" {
  name         = "${var.project_name}-${var.environment}-application-state"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "entity_id"
  range_key = "record_type"

  attribute {
    name = "entity_id"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-application-state"
    Environment = var.environment
    Tier        = "Database"
    Purpose     = "ApplicationState"
    ManagedBy   = "Terraform"
  }
}

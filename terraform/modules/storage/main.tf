resource "aws_s3_bucket" "application_data" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Purpose     = "ApplicationData"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  depends_on = [
    aws_s3_bucket_versioning.application_data
  ]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

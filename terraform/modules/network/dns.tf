resource "aws_route53_zone" "private" {
  name = "lab.internal"

  vpc {
    vpc_id = aws_vpc.this.id
  }

  comment = "Private DNS zone for the AWS Enterprise Cloud Lab."

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-zone"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

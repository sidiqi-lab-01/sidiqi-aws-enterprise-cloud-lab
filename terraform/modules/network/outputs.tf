output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs."
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs."
  value = {
    for key, subnet in aws_subnet.private : key => subnet.id
  }
}

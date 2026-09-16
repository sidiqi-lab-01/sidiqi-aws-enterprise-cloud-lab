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

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = aws_route_table.private.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "application_security_group_id" {
  description = "ID of the application workload security group."
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.database.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 Gateway VPC endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "ssm_vpc_endpoint_id" {
  description = "ID of the SSM interface VPC endpoint."
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "ID of the SSM Messages interface VPC endpoint."
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "ID of the EC2 Messages interface VPC endpoint."
  value       = aws_vpc_endpoint.ec2_messages.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group."
  value       = aws_security_group.vpc_endpoints.id
}

output "private_hosted_zone_id" {
  description = "ID of the Route 53 private hosted zone."
  value       = aws_route53_zone.private.zone_id
}

output "private_hosted_zone_name" {
  description = "Name of the Route 53 private hosted zone."
  value       = aws_route53_zone.private.name
}

output "application_load_balancer_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.application.arn
}

output "application_load_balancer_dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_lb.application.dns_name
}

output "application_load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the application load balancer."
  value       = aws_lb.application.zone_id
}

output "application_target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.application.arn
}

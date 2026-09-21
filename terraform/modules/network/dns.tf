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

resource "aws_route53_zone" "public" {
  name = var.public_domain_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-zone"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_acm_certificate" "application" {
  domain_name       = var.application_domain_name
  validation_method = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-application-certificate"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "application_certificate_validation" {
  for_each = {
    (var.application_domain_name) = {
      name = one([
        for option in aws_acm_certificate.application.domain_validation_options :
        option.resource_record_name
        if option.domain_name == var.application_domain_name
      ])

      record = one([
        for option in aws_acm_certificate.application.domain_validation_options :
        option.resource_record_value
        if option.domain_name == var.application_domain_name
      ])

      type = one([
        for option in aws_acm_certificate.application.domain_validation_options :
        option.resource_record_type
        if option.domain_name == var.application_domain_name
      ])
    }
  }

  zone_id = aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "application" {
  certificate_arn = aws_acm_certificate.application.arn

  validation_record_fqdns = [
    for record in aws_route53_record.application_certificate_validation :
    record.fqdn
  ]
}

resource "aws_route53_record" "application" {
  zone_id = aws_route53_zone.public.zone_id
  name    = var.application_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.application.dns_name
    zone_id                = aws_lb.application.zone_id
    evaluate_target_health = true
  }
}

variable "domain" {}
variable "root_domain" {}
variable "region" {}
variable "additional_names" {
  type    = list
  default = []
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = var.additional_names
  tags                      = {
    Project = var.root_domain
    Name    = var.root_domain
  }
}

data "aws_route53_zone" "root_domain_zone" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "record" {
  for_each = {
    for dns in aws_acm_certificate.certificate.domain_validation_options : dns.domain_name => {
      name   = dns.resource_record_name
      record = dns.resource_record_value
      type   = dns.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_domain_zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}

output "arn" {
  value = aws_acm_certificate_validation.validation.certificate_arn
}
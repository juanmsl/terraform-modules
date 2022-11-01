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

output "arn" {
  value = aws_acm_certificate.certificate.arn
}
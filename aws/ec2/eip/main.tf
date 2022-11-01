variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc" {
  default = true
}

locals {
  name      = join("-", [var.project, var.environment, var.role])
  tags      = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ec2"
  }
}

resource "aws_eip" "eip" {
  vpc = var.vpc
  tags = local.tags
}

output "id" {
  value = aws_eip.eip.id
}

output "private_ip" {
  value = aws_eip.eip.private_ip
}

output "private_dns" {
  value = aws_eip.eip.private_dns
}

output "public_ip" {
  value = aws_eip.eip.public_ip
}

output "public_dns" {
  value = aws_eip.eip.public_dns
}
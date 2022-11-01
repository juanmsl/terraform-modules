variable "project" {}
variable "environment" {}
variable "vpc_id" {}

locals {
  name = join("-", [var.project, var.environment])

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    AWSService  = "vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id
  tags   = local.tags
}

output "id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "arn" {
  value = aws_internet_gateway.internet_gateway.arn
}
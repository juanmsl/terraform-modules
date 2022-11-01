variable "project" {}
variable "environment" {}
variable "role" {}
variable "cidr_block" {}
variable "availability_zone" {}
variable "vpc_id" {}
variable "is_public" {}

locals {
  scope = var.is_public ? "public" : "private"
  name  = join("-", [local.scope, var.project, var.environment, var.role])

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Scope       = local.scope
    AWSService  = "vpc"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.is_public
  vpc_id                  = var.vpc_id
  tags                    = local.tags
}

output "id" {
  value = aws_subnet.subnet.id
}

output "cidr" {
  value = aws_subnet.subnet.cidr_block
}

output "arn" {
  value = aws_subnet.subnet.arn
}
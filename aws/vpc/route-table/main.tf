variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc_id" {}
variable "is_public" {}

locals {
  scope = var.is_public ? "public" : "private"
  name  = join("-", [local.scope, var.project, var.environment, var.role])

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    Scope       = local.scope
    AWSService  = "vpc"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags   = local.tags
}

output "id" {
  value = aws_route_table.route_table.id
}
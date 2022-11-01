variable "project" {}
variable "environment" {}
variable "family" {}
variable "parameters" {
  type    = list
  default = []
}

locals {
  name = join("-", [var.project, var.environment, var.family])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.family
    AWSService  = "rds"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = local.name
  family = var.family
  tags   = local.tags

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

output "name" {
  value = aws_db_parameter_group.parameter_group.name
}

output "arn" {
  value = aws_db_parameter_group.parameter_group.arn
}

output "id" {
  value = aws_db_parameter_group.parameter_group.id
}
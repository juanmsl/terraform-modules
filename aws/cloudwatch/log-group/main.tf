variable "project" {}
variable "environment" {}
variable "role" {}
variable "service" {}
variable "retention_in_days" {
  default = 180
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = var.service
  }
}

resource "aws_cloudwatch_log_group" "module" {
  name              = "/${var.service}/${local.name}"
  tags              = local.tags
  retention_in_days = var.retention_in_days
}

output "name" {
  value = aws_cloudwatch_log_group.module.name
}

output "arn" {
  value = aws_cloudwatch_log_group.module.arn
}

output "id" {
  value = aws_cloudwatch_log_group.module.id
}
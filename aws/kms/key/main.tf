variable "project" {}
variable "environment" {}
variable "role" {
  default = "key"
}
variable "policy" {
  default = ""
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "kms"
  }
}

resource "aws_kms_key" "key" {
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = var.policy
  tags                    = local.tags
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.key.key_id
}

output "arn" {
  value = aws_kms_key.key.arn
}

output "key_id" {
  value = aws_kms_key.key.key_id
}

output "name" {
  value = aws_kms_alias.alias.name
}
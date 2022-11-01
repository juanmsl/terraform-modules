variable "project" {}
variable "environment" {}
variable "role" {}
variable "availability_zone" {}
variable "size" {}
variable "type" {}
variable "kms_key_id" {
  default = ""
}

locals {
  name      = join("-", [var.project, var.environment, var.role])
  encrypted = var.kms_key_id != ""
  tags      = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ec2"
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  encrypted         = local.encrypted
  kms_key_id        = var.kms_key_id
  size              = var.size
  type              = var.type
  tags              = local.tags
}

output "id" {
  value = aws_ebs_volume.ebs_volume.id
}

output "arn" {
  value = aws_ebs_volume.ebs_volume.arn
}

variable "project" {}
variable "environment" {}
variable "role" {}
variable "subnets" {}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "efs"
  }
}

resource "aws_efs_file_system" "file_system" {
  tags = local.tags
}

resource "aws_efs_access_point" "file_system_access_point" {
  file_system_id = aws_efs_file_system.file_system.id
  tags           = local.tags
}

resource "aws_efs_mount_target" "fs_mount_target" {
  for_each       = toset(var.subnets)
  file_system_id = aws_efs_file_system.file_system.id
  subnet_id      = each.value
}

output "id" {
  value = aws_efs_file_system.file_system.id
}

output "access_point_id" {
  value = aws_efs_access_point.file_system_access_point.id
}
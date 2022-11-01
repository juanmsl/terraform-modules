variable "project" {}
variable "environment" {}
variable "role" {}
variable "subnets" {
  type = list
}
variable "security_group_ids" {
  type = list
}
variable "allocated_storage" {
  default = 20
}
variable "max_allocated_storage" {}
variable "instance_class" {}
variable "engine" {}
variable "engine_version" {}
variable "storage_type" {
  default = "gp2"
}
variable "port" {}
variable "snapshot_identifier" {
  default = ""
}
variable "kms_key_id" {
  default = ""
}
variable "parameter_group_name" {
  default = ""
}
variable "backup_retention_period" {}
variable "backup_window" {
  default = "04:30-05:00"
}
variable "cloudwatch_logs_exports" {
  type    = list
  default = []
}
variable "apply_immediately" {
  default = false
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "rds"
  }
}

resource "random_id" "password" {
  byte_length = 20
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = local.name
  subnet_ids = var.subnets
  tags       = local.tags
}

resource "aws_db_instance" "instance" {
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  engine                          = var.engine
  engine_version                  = var.engine_version
  storage_type                    = var.storage_type
  db_name                         = replace(local.name, "-", "")
  username                        = "aws_master_admin"
  password                        = random_id.password.hex
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  parameter_group_name            = var.parameter_group_name
  vpc_security_group_ids          = var.security_group_ids
  publicly_accessible             = false
  port                            = var.port
  snapshot_identifier             = var.snapshot_identifier
  final_snapshot_identifier       = "${local.name}-final-snapshot"
  copy_tags_to_snapshot           = true
  multi_az                        = length(var.subnets) > 1
  storage_encrypted               = var.kms_key_id != ""
  kms_key_id                      = var.kms_key_id
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  identifier                      = local.name
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  deletion_protection             = true
  apply_immediately               = var.apply_immediately
  tags                            = local.tags

  lifecycle {
    ignore_changes = [engine_version]
  }
}

output "host" {
  value = aws_db_instance.instance.address
}

output "port" {
  value = aws_db_instance.instance.port
}

output "username" {
  value = aws_db_instance.instance.username
}

output "password" {
  value = aws_db_instance.instance.password
}

output "name" {
  value = aws_db_instance.instance.name
}

output "id" {
  value = aws_db_instance.instance.id
}

output "arn" {
  value = aws_db_instance.instance.arn
}
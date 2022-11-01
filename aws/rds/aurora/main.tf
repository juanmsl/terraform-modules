variable "project" {}
variable "environment" {}
variable "role" {}
variable "subnets" {
  type = list
}
variable "security_group_ids" {
  type = list
}
variable "engine" {
  default = "aurora-postgresql"
}
variable "engine_version" {
  default = "10.7"
}
variable "engine_mode" {
  default = "serverless"
}
variable "port" {
  default = "5432"
}
variable "snapshot_identifier" {
  default = ""
}
variable "kms_key_id" {
  default = ""
}
variable "parameter_group_name" {
  default = ""
}
variable "backup_retention_period" {
  default = 30
}
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
variable "auto_pause" {
  default = true
}
variable "seconds_until_auto_pause" {
  default = "300"
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
  byte_length = 32
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = local.name
  subnet_ids = var.subnets
  tags       = local.tags
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier              = local.name
  database_name                   = replace(local.name, "-", "")
  vpc_security_group_ids          = var.security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  engine_mode                     = var.engine_mode
  deletion_protection             = true
  master_username                 = "aws_master_admin"
  master_password                 = random_id.password.hex
  db_cluster_parameter_group_name = var.parameter_group_name
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  snapshot_identifier             = var.snapshot_identifier
  final_snapshot_identifier       = "${local.name}-final-snapshot"
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  copy_tags_to_snapshot           = true
  storage_encrypted               = var.kms_key_id != ""
  kms_key_id                      = var.kms_key_id
  port                            = var.port
  apply_immediately               = var.apply_immediately
  tags                            = local.tags

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = var.seconds_until_auto_pause
  }

  lifecycle {
    ignore_changes = [
      "engine_version",
    ]
  }
}

output "host" {
  value = split(":", aws_rds_cluster.cluster.endpoint)[0]
}

output "port" {
  value = aws_rds_cluster.cluster.port
}

output "username" {
  value = aws_rds_cluster.cluster.master_username
}

output "password" {
  value = aws_rds_cluster.cluster.master_password
}

output "name" {
  value = aws_rds_cluster.cluster.database_name
}

output "id" {
  value = aws_rds_cluster.cluster.id
}

output "arn" {
  value = aws_rds_cluster.cluster.arn
}
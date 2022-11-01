variable "project" {}
variable "environment" {}
variable "max_allocated_storage" {}
variable "backup_retention_period" {}
variable "engine" {
  default = "mysql"
}
variable "engine_version" {}
variable "instance_class" {
  default = "db.t4g.medium"
}
variable "port" {
  default = 3306
}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnets" {
  type = list
}

module "rds" {
  source                  = "../../../modules/aws/rds/instance"
  project                 = var.project
  environment             = var.environment
  role                    = "database"
  max_allocated_storage   = var.max_allocated_storage
  apply_immediately       = true
  backup_retention_period = var.backup_retention_period
  port                    = var.port
  subnets                 = var.subnets
  security_group_ids      = [module.security_group.id]
  instance_class          = var.instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
}

module "security_group" {
  source      = "../../aws/vpc/security-group"
  environment = var.environment
  project     = var.project
  role        = "database"
  vpc_id      = var.vpc_id
  rules             = {
    "tcp,ingress,${var.port},${var.port}" = [var.vpc_cidr]
    "-1,egress,0,0"                     = ["0.0.0.0/0"]
  }
}

output "host" {
  value = module.rds.host
}

output "port" {
  value = module.rds.port
}

output "username" {
  value = module.rds.username
}

output "password" {
  value = module.rds.password
}

output "name" {
  value = module.rds.name
}

output "id" {
  value = module.rds.id
}

output "arn" {
  value = module.rds.arn
}

output "security_group_id" {
  value = module.security_group.id
}
variable "project" {}
variable "environment" {}
variable "private" {
  default = false
}
variable "fargate_spot" {
  default = false
}
variable "container_port" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "ecs_cluster_name" {}
variable "ecs_security_group_id" {}
variable "load_balancer_container_name" {}
variable "health_check_path" {}
variable "certificate_arn" {}
variable "task_definition_arn" {}
variable "ssl_policy" {
  default = "ELBSecurityPolicy-2016-08"
}
variable "public_subnets" {
  type = list
}
variable "private_subnets" {
  type = list
}
variable "platform_version" {
  default = "LATEST"
}

locals {
  role = var.private ? "private" : "public"
}

module "service" {
  source                         = "../../aws/ecs/service"
  project                        = var.project
  environment                    = var.environment
  role                           = "service-${local.role}"
  desired_count                  = 1
  ecs_cluster_name               = var.ecs_cluster_name
  load_balancer_container_name   = var.load_balancer_container_name
  load_balancer_container_port   = var.container_port
  load_balancer_target_group_arn = module.target_group.arn
  security_group_ids             = [module.security_group_service.id]
  subnets                        = var.private_subnets
  fargate_spot                   = var.fargate_spot
  task_definition_arn            = var.task_definition_arn
  platform_version               = var.platform_version
}

module "security_group_service" {
  source                = "../../aws/vpc/security-group"
  project               = var.project
  environment           = var.environment
  role                  = "service-${local.role}"
  vpc_id                = var.vpc_id
  rules_security_groups = {
    "tcp,ingress,0,65535" = var.ecs_security_group_id
  }
  rules = {
    "tcp,ingress,${var.container_port},${var.container_port}"   = var.private ? [var.vpc_cidr] : ["0.0.0.0/0"]
    "-1,ingress,2049,2049" = ["0.0.0.0/0"]
    "-1,egress,0,0" = ["0.0.0.0/0"]
  }
}

module "load-balancer" {
  source             = "../../aws/ec2/alb"
  project            = var.project
  environment        = var.environment
  role               = "alb-${local.role}"
  internal           = var.private
  security_group_ids = [module.security_group_load_balancer.id]
  subnets            = var.private ? var.private_subnets : var.public_subnets
}

module "security_group_load_balancer" {
  source      = "../../aws/vpc/security-group"
  project     = var.project
  environment = var.environment
  role        = "alb-${local.role}"
  vpc_id      = var.vpc_id
  rules       = {
    "tcp,ingress,80,80"   = var.private ? [var.vpc_cidr] : ["0.0.0.0/0"]
    "tcp,ingress,443,443" = var.private ? [var.vpc_cidr] : ["0.0.0.0/0"]
    "-1,egress,0,0"       = ["0.0.0.0/0"]
  }
}

module "target_group" {
  source       = "../../aws/ec2/alb/target-group"
  project      = var.project
  role         = "alb-${local.role}"
  environment  = var.environment
  vpc_id       = var.vpc_id
  port         = var.container_port
  health_check = {
    path = var.health_check_path
  }
}

module "listener_http" {
  source            = "../../aws/ec2/listener/http"
  load_balancer_arn = module.load-balancer.arn
}

module "listener_https" {
  source            = "../../aws/ec2/listener/https"
  load_balancer_arn = module.load-balancer.arn
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  target_group_arn  = module.target_group.arn
}

output "role" {
  value = local.role
}

output "load_balancer_dns_name" {
  value = module.load-balancer.dns_name
}

output "service_security_group_id" {
  value = module.security_group_service.id
}

output "service_name" {
  value = module.service.name
}
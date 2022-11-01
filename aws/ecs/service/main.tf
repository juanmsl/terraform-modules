variable "project" {}
variable "environment" {}
variable "role" {}
variable "task_definition_arn" {}
variable "desired_count" {}
variable "ecs_cluster_name" {}
variable "subnets" {}
variable "security_group_ids" {}
variable "load_balancer_target_group_arn" {}
variable "load_balancer_container_name" {}
variable "load_balancer_container_port" {}
variable "fargate_spot" {}
variable "platform_version" {
  default = "LATEST"
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ecs"
  }
}

resource "aws_ecs_service" "service" {
  name             = local.name
  task_definition  = var.task_definition_arn
  desired_count    = var.desired_count
  cluster          = var.ecs_cluster_name
  launch_type      = var.fargate_spot ? null : "FARGATE"
  propagate_tags   = "TASK_DEFINITION"
  tags             = local.tags
  platform_version = var.platform_version

  dynamic "capacity_provider_strategy" {
    for_each = var.fargate_spot ? [true] : []

    content {
      base              = 1
      weight            = 100
      capacity_provider = "FARGATE_SPOT"
    }
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.load_balancer_target_group_arn
    container_name   = var.load_balancer_container_name
    container_port   = var.load_balancer_container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

output "id" {
  value = aws_ecs_service.service.id
}

output "name" {
  value = aws_ecs_service.service.name
}

output "cluster" {
  value = aws_ecs_service.service.cluster
}

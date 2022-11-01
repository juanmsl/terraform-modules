variable "project" {}
variable "environment" {}
variable "role" {}
variable "cpu" {}
variable "memory" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "container_definitions" {}
variable "efs_name" {}
variable "efs_id" {}
variable "efs_access_point_id" {}

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

resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = var.container_definitions
  family                   = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  tags                     = local.tags

  volume {
    name = var.efs_name

    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "DISABLED"
      }
    }
  }
}

output "arn" {
  value = aws_ecs_task_definition.task_definition.arn
}

output "family" {
  value = aws_ecs_task_definition.task_definition.family
}

output "revision" {
  value = aws_ecs_task_definition.task_definition.revision
}
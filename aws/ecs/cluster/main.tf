variable "project" {}
variable "environment" {}
variable "fargate_spot" {}

locals {
  name = join("-", [var.project, var.environment])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    AWSService  = "ecs"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = local.name
  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers_fargate" {
  count              = var.fargate_spot ? 1 : 0
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

output "id" {
  value = aws_ecs_cluster.cluster.id
}

output "arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "name" {
  value = aws_ecs_cluster.cluster.name
}

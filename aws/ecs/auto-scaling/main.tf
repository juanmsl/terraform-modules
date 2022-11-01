variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "max_capacity" {
  default = 5
}
variable "min_capacity" {
  default = 1
}
variable "scalable_dimension" {
  default = "ecs:service:DesiredCount"
}
variable "service_namespace" {
  default = "ecs"
}
variable "cooldown" {
  default = 300
}
variable "cpu_limit" {
  default = 60
}
variable "memory_limit" {
  default = 80
}

resource "aws_appautoscaling_target" "asg_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
}

resource "aws_appautoscaling_policy" "asg_policy_remove" {
  name               = "${var.ecs_service_name}-memory-policy"
  resource_id        = aws_appautoscaling_target.asg_target.resource_id
  scalable_dimension = aws_appautoscaling_target.asg_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.asg_target.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown = var.cooldown
    target_value      = var.memory_limit
  }
}

resource "aws_appautoscaling_policy" "asg_policy_create" {
  name               = "${var.ecs_service_name}-cpu-policy"
  resource_id        = aws_appautoscaling_target.asg_target.resource_id
  scalable_dimension = aws_appautoscaling_target.asg_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.asg_target.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown = var.cooldown
    target_value      = var.cpu_limit
  }
}

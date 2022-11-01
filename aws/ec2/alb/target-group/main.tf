variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc_id" {}
variable "port" {}
variable "deregistration_delay" {
  default = 60
}
variable "health_check" {
  type = map
  #  {
  #    path                = "/ping"
  #    interval            = 30 // optional
  #    timeout             = 5 // optional
  #    healthy_threshold   = 5 // optional
  #    unhealthy_threshold = 5 // optional
  #    matcher             = 5 // optional
  #  }
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ec2"
  }
}

resource "aws_lb_target_group" "target_group" {
  name                 = format("%.32s", local.name)
  vpc_id               = var.vpc_id
  port                 = var.port
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay
  tags                 = local.tags

  health_check {
    path                = lookup(var.health_check, "path")
    interval            = lookup(var.health_check, "interval", 30)
    timeout             = lookup(var.health_check, "timeout", 15)
    healthy_threshold   = lookup(var.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(var.health_check, "unhealthy_threshold", 3)
    matcher             = lookup(var.health_check, "matcher", 200)
    protocol            = "HTTP"
  }
}

output "id" {
  value = aws_lb_target_group.target_group.id
}

output "arn" {
  value = aws_lb_target_group.target_group.arn
}

output "name" {
  value = aws_lb_target_group.target_group.name
}
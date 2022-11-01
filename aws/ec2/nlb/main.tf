variable "project" {}
variable "environment" {}
variable "role" {}
variable "security_group_ids" {}
variable "internal" {}
variable "enable_cross_zone_load_balancing" {
  default = false
}
variable "subnets" {
  type    = "list"
  default = []
}
variable "subnet_private_mapping" {
  type    = "map"
  default = {}
  # {
  #   subnet-id-1 = "private-ip"
  #   subnet-id-2 = "private-ip"
  # }
}
variable "subnet_public_mapping" {
  type    = "map"
  default = {}
  # {
  #   subnet-id-1 = "eip-id"
  #   subnet-id-2 = "eip-id"
  # }
}
variable "access_logs_bucket_name" {
  default = ""
}

locals {
  name        = join("-", [var.project, var.environment, var.role])
  access_logs = var.access_logs_bucket_name == "" ? [] : [var.access_logs_bucket_name]
  tags        = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ec2"
  }
}

resource "aws_lb" "lb" {
  name                             = local.name
  load_balancer_type               = "network"
  enable_deletion_protection       = true
  internal                         = var.internal
  tags                             = local.tags
  subnets                          = var.subnets
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "subnet_mapping" {
    for_each = var.subnet_private_mapping
    content {
      subnet_id            = subnet_mapping.key
      private_ipv4_address = subnet_mapping.value
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_public_mapping
    content {
      subnet_id     = subnet_mapping.key
      allocation_id = subnet_mapping.value
    }
  }

  dynamic "access_logs" {
    for_each = local.access_logs
    content {
      bucket  = access_logs.value
      prefix  = join("/", [var.project, var.environment, var.role])
      enabled = true
    }
  }
}

output "id" {
  value = aws_lb.lb.id
}

output "arn" {
  value = aws_lb.lb.arn
}

output "dns_name" {
  value = aws_lb.lb.dns_name
}

output "zone_id" {
  value = aws_lb.lb.zone_id
}

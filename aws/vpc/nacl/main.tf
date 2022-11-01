variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list
  default = []
}
variable "egress_rules" {
  type = map
  default = {}
  #  {
  #    "100,allow,tcp,20,50" = "10.0.0.0/8"
  #    "200,deny,tcp,80,80" = "172.16.0.0/20"
  #  }
}
variable "ingress_rules" {
  type = map
  default = {}
  #  {
  #    "100,allow,tcp,20,50" = "10.0.0.0/8"
  #    "200,deny,tcp,80,80" = "172.16.0.0/20"
  #  }
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "vpc"
  }
}

resource "aws_network_acl" "network_acl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  tags       = local.tags

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      rule_no    = split(",", egress.key)[0]
      action     = split(",", egress.key)[1]
      protocol   = split(",", egress.key)[2]
      from_port  = split(",", egress.key)[3]
      to_port    = split(",", egress.key)[4]
      cidr_block = egress.value
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      rule_no    = split(",", ingress.key)[0]
      action     = split(",", ingress.key)[1]
      protocol   = split(",", ingress.key)[2]
      from_port  = split(",", ingress.key)[3]
      to_port    = split(",", ingress.key)[4]
      cidr_block = ingress.value
    }
  }
}

output "id" {
  value = aws_network_acl.network_acl.id
}

output "arn" {
  value = aws_network_acl.network_acl.arn
}

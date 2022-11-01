variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc_id" {}
variable "rules" {
  type    = map
  #  {
  #    "tcp,egress,20,50" = ["10.0.0.0/8", "172.16.0.0/20"]
  #    "tcp,ingress,80,80" = ["10.0.0.0/8", "172.16.0.0/20"]
  #  }
  default = {}
}
variable "rules_security_groups" {
  type    = map
  #  {
  #    "tcp,egress,20,50" = "id-sg"
  #    "tcp,ingress,80,80" = "id-sg"
  #  }
  default = {}
}
variable "rules_self" {
  type    = list
  #  [
  #    "tcp,egress,20,50",
  #    "tcp,ingress,80,80"
  #  ]
  default = []
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

resource "aws_security_group" "security_group" {
  name   = local.name
  vpc_id = var.vpc_id
  tags   = local.tags
}

resource "aws_security_group_rule" "security_group_rule" {
  for_each          = var.rules
  security_group_id = aws_security_group.security_group.id
  protocol          = split(",", each.key)[0]
  type              = split(",", each.key)[1]
  from_port         = split(",", each.key)[2]
  to_port           = split(",", each.key)[3]
  cidr_blocks       = each.value
}

resource "aws_security_group_rule" "security_group_rule_sg" {
  for_each                 = var.rules_security_groups
  security_group_id        = aws_security_group.security_group.id
  protocol                 = split(",", each.key)[0]
  type                     = split(",", each.key)[1]
  from_port                = split(",", each.key)[2]
  to_port                  = split(",", each.key)[3]
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "security_group_rule_self" {
  for_each          = toset(var.rules_self)
  security_group_id = aws_security_group.security_group.id
  protocol          = split(",", each.value)[0]
  type              = split(",", each.value)[1]
  from_port         = split(",", each.value)[2]
  to_port           = split(",", each.value)[3]
  self              = true
}

output "id" {
  value = aws_security_group.security_group.id
}

output "arn" {
  value = aws_security_group.security_group.arn
}

output "name" {
  value = aws_security_group.security_group.name
}

variable "security_group_id" {}
variable "rules" {
  type = map
  default = {}
  #  {
  #    "tcp,egress,20,50" = ["10.0.0.0/8", "172.16.0.0/20"]
  #    "tcp,ingress,80,80" = ["10.0.0.0/8", "172.16.0.0/20"]
  #  }
}
variable "rules_security_groups" {
  type = map
  default = {}
  #  {
  #    "tcp,egress,20,50" = "id-sg"
  #    "tcp,ingress,80,80" = "id-sg"
  #  }
}
variable "rules_self" {
  type = list
  default = []
  #  [
  #    "tcp,egress,20,50",
  #    "tcp,ingress,80,80"
  #  ]
}

resource "aws_security_group_rule" "security_group_rule" {
  for_each          = var.rules
  security_group_id = var.security_group_id
  protocol          = split(",", each.key)[0]
  type              = split(",", each.key)[1]
  from_port         = split(",", each.key)[2]
  to_port           = split(",", each.key)[3]
  cidr_blocks       = each.value
}

resource "aws_security_group_rule" "security_group_rule_sg" {
  for_each                 = var.rules_security_groups
  security_group_id        = var.security_group_id
  protocol                 = split(",", each.key)[0]
  type                     = split(",", each.key)[1]
  from_port                = split(",", each.key)[2]
  to_port                  = split(",", each.key)[3]
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "security_group_rule_self" {
  for_each          = toset(var.rules_self)
  security_group_id = var.security_group_id
  protocol          = split(",", each.value)[0]
  type              = split(",", each.value)[1]
  from_port         = split(",", each.value)[2]
  to_port           = split(",", each.value)[3]
  self              = true
}
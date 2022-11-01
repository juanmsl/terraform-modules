variable "project" {}
variable "environment" {}
variable "cidr_block" {}

locals {
  name = join("-", [var.project, var.environment])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    AWSService  = "vpc"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_default_security_group" "vpc_security_group" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_main_route_table_association" "default_route_table_association" {
  route_table_id = aws_route_table.default_route_table.id
  vpc_id         = aws_vpc.vpc.id
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  tags                   = local.tags

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

output "arn" {
  value = aws_vpc.vpc.arn
}

output "id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "default_security_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}

output "default_route_table_id" {
  value = aws_vpc.vpc.default_route_table_id
}

output "default_network_acl_id" {
  value = aws_vpc.vpc.default_network_acl_id
}
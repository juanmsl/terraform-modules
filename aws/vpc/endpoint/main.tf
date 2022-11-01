variable "project" {}
variable "environment" {}
variable "service_name" {}
variable "vpc_id" {}
variable "vpc_route_table_ids" {
  type    = list
  default = []
}
variable "security_group_ids" {
  type    = list
  default = []
}
variable "subnet_ids" {
  type    = list
  default = []
}
variable "private_dns_enabled" {
  default = false
}

data "aws_vpc_endpoint_service" "vpc_endpoint_service" {
  service = var.service_name
}

locals {
  name                      = join("-", [var.project, var.environment, var.service_name])
  vpc_endpoint_service_type = data.aws_vpc_endpoint_service.vpc_endpoint_service.service_type
  vpc_endpoint_service_name = data.aws_vpc_endpoint_service.vpc_endpoint_service.service_name
  tags                      = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    AWSService  = "vpc"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = local.vpc_endpoint_service_name
  vpc_endpoint_type   = local.vpc_endpoint_service_type
  route_table_ids     = local.vpc_endpoint_service_type == "Gateway" ? var.vpc_route_table_ids : []
  security_group_ids  = local.vpc_endpoint_service_type == "Interface" ? var.security_group_ids : []
  subnet_ids          = local.vpc_endpoint_service_type == "Interface" ? var.subnet_ids : []
  private_dns_enabled = local.vpc_endpoint_service_type == "Interface" ? var.private_dns_enabled : false
  tags                = local.tags
}

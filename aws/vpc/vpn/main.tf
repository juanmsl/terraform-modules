variable "project" {}
variable "environment" {}
variable "role" {}
variable "vpc_id" {}
variable "psk1" {}
variable "psk2" {}
variable "ip_address" {}
variable "encryption_domains" {
  type = list
}
variable "type" {
  default = "ipsec.1"
}
variable "static_routes_only" {
  default = true
}
variable "bgp_asn" {
  default = 65000
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

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
  tags   = local.tags
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = var.bgp_asn
  ip_address = var.ip_address
  type       = var.type
  tags       = local.tags
}

resource "aws_vpn_connection" "vpn_connection" {
  vpn_gateway_id        = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id   = aws_customer_gateway.customer_gateway.id
  type                  = var.type
  static_routes_only    = var.static_routes_only
  tunnel1_preshared_key = var.psk1
  tunnel2_preshared_key = var.psk2
  tags                  = local.tags
}

resource "aws_vpn_connection_route" "vpn_connection_route" {
  count                  = length(var.encryption_domains)
  destination_cidr_block = var.encryption_domains[count.index]
  vpn_connection_id      = aws_vpn_connection.vpn_connection.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gateway.id
}

output "vpn_gateway_arn" {
  value = aws_vpn_gateway.vpn_gateway.arn
}

output "customer_gateway_id" {
  value = aws_customer_gateway.customer_gateway.id
}

output "customer_gateway_arn" {
  value = aws_customer_gateway.customer_gateway.arn
}

output "vpn_connection_id" {
  value = aws_vpn_connection.vpn_connection.id
}

output "vpn_connection_arn" {
  value = aws_vpn_connection.vpn_connection.arn
}

output "vpn_connection_tunnel1_address" {
  value = aws_vpn_connection.vpn_connection.tunnel1_address
}

output "vpn_connection_tunnel2_address" {
  value = aws_vpn_connection.vpn_connection.tunnel2_address
}
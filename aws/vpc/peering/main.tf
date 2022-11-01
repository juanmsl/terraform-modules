variable "project" {}
variable "environment" {}
variable "role" {}

variable "requester_vpc_id" {}
variable "requester_vpc_cidr" {}
variable "requester_route_table_ids" {
  type = list
}

variable "accepter_vpc_id" {}
variable "accepter_vpc_cidr" {}
variable "accepter_route_table_ids" {
  type = list
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

resource "aws_vpc_peering_connection" "peering_connection" {
  peer_vpc_id = var.accepter_vpc_id
  vpc_id      = var.requester_vpc_id
  auto_accept = false
  tags        = merge(local.tags, {
    Side = "requester"
  })
}

resource "aws_route" "peering_connection_route" {
  count                     = length(var.requester_route_table_ids)
  route_table_id            = var.requester_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

resource "aws_route" "peering_connection_accepter_route" {
  count                     = length(var.accepter_route_table_ids)
  route_table_id            = var.accepter_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  provider                  = "aws.accepter-account"
}

resource "aws_vpc_peering_connection_accepter" "peering_connection_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  auto_accept               = true
  provider                  = "aws.accepter-account"
  tags                      = merge(local.tags, {
    Side = "accepter"
  })
}

output "id" {
  value = aws_vpc_peering_connection.peering_connection.id
}

output "status" {
  value = aws_vpc_peering_connection.peering_connection.accept_status
}
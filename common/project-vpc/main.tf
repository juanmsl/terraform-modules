variable "region" {}
variable "project" {}
variable "environment" {}
variable "cidr_block" {}
variable "newbits" {
  default = 8
}
variable "azs" {}
variable "private_subnet_count" {
  default = 3
}
variable "public_subnet_count" {
  default = 3
}

module "vpc" {
  source      = "../../aws/vpc"
  cidr_block  = var.cidr_block
  environment = var.environment
  project     = var.project
}

module "internet_gateway" {
  source      = "../../aws/vpc/internet-gateway"
  environment = var.environment
  project     = var.project
  vpc_id      = module.vpc.id
}

module "subnets_public" {
  source            = "../../aws/vpc/subnet"
  environment       = var.environment
  project           = var.project
  role              = count.index
  is_public         = true
  vpc_id            = module.vpc.id
  availability_zone = "${var.region}${element(split(",", var.azs), count.index)}"
  cidr_block        = cidrsubnet(var.cidr_block, var.newbits, count.index)
  count             = var.public_subnet_count
}

module "subnets_private" {
  source            = "../../aws/vpc/subnet"
  environment       = var.environment
  project           = var.project
  role              = count.index
  is_public         = false
  vpc_id            = module.vpc.id
  availability_zone = "${var.region}${element(split(",", var.azs), count.index)}"
  cidr_block        = cidrsubnet(var.cidr_block, var.newbits, count.index + var.public_subnet_count)
  count             = var.private_subnet_count
}

module "route_tables_public" {
  source      = "../../aws/vpc/route-table"
  environment = var.environment
  project     = var.project
  is_public   = true
  role        = count.index
  vpc_id      = module.vpc.id
  count       = var.public_subnet_count
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = module.subnets_public.*.id[count.index]
  route_table_id = module.route_tables_public.*.id[count.index]
}

resource "aws_route" "internet_gateway" {
  count                  = var.public_subnet_count
  route_table_id         = module.route_tables_public.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet_gateway.id
  depends_on             = [module.route_tables_public]
}

module "route_tables_private" {
  source      = "../../aws/vpc/route-table"
  environment = var.environment
  project     = var.project
  is_public   = false
  role        = count.index
  vpc_id      = module.vpc.id
  count       = var.public_subnet_count
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = module.subnets_private.*.id[count.index]
  route_table_id = module.route_tables_private.*.id[count.index]
}

output "private_subnets" {
  value = module.subnets_private.*.id
}

output "private_subnets_cidr" {
  value = module.subnets_private.*.cidr
}

output "public_subnets" {
  value = module.subnets_public.*.id
}

output "public_subnets_cidr" {
  value = module.subnets_public.*.cidr
}

output "vpc_id" {
  value = module.vpc.id
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "default_network_acl_id" {
  value = module.vpc.default_network_acl_id
}

output "default_route_table_id" {
  value = module.vpc.default_route_table_id
}

output "private_route_table_id" {
  value = module.route_tables_private.*.id
}

output "public_route_table_id" {
  value = module.route_tables_public.*.id
}

output "route_table_ids" {
  value = concat(module.route_tables_private.*.id, module.route_tables_public.*.id)
}

output "route_tables_count" {
  value = var.public_subnet_count + var.private_subnet_count
}
variable "project" {}
variable "environment" {}
variable "public_subnet_id" {}

locals {
  name = join("-", [var.project, var.environment])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    AWSService  = "vpc"
  }
}

resource "aws_eip" "eip" {
  vpc  = true
  tags = local.tags
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_subnet_id
  tags          = local.tags
}

output "id" {
  value = aws_nat_gateway.nat.id
}

output "public_ip" {
  value = aws_nat_gateway.nat.public_ip
}

output "private_ip" {
  value = aws_nat_gateway.nat.private_ip
}
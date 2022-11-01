variable "project" {}
variable "environment" {}
variable "role" {}
variable "ami" {}
variable "key_name" {}
variable "security_group_ids" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "monitoring" {
  default = true
}
variable "instance_type" {
  default = "t2.micro"
}
variable "private_ip" {
  default = ""
}
variable "secondary_private_ips" {
  type    = "list"
  default = []
}
variable "associate_public_ip_address" {
  default = true
}
variable "source_dest_check" {
  default = true
}
variable "user_data" {
  default = ""
}
variable "root_block_device" {
  type    = "map"
  default = {}
  # {
  #   volume_type = "gp2"
  #   volume_size = 8
  #   delete_on_termination = true // default (false)
  # }
}

locals {
  name              = join("-", [var.project, var.environment, var.role])
  root_block_device = var.root_block_device == {} ? [] : [var.root_block_device]
  tags              = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "ec2"
  }
}

resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  tags                        = local.tags
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  source_dest_check           = var.source_dest_check
  user_data                   = var.user_data
  iam_instance_profile        = var.iam_instance_profile
  monitoring                  = var.monitoring
  disable_api_termination     = true

  dynamic "root_block_device" {
    for_each = local.root_block_device
    content {
      volume_type           = lookup(root_block_device.value, "volume_type")
      volume_size           = lookup(root_block_device.value, "volume_size")
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
    }
  }
}

output "id" {
  value = aws_instance.instance.id
}

output "arn" {
  value = aws_instance.instance.arn
}

output "availability_zone" {
  value = aws_instance.instance.availability_zone
}

output "public_dns" {
  value = aws_instance.instance.public_dns
}

output "private_dns" {
  value = aws_instance.instance.private_dns
}

output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "private_ip" {
  value = aws_instance.instance.private_ip
}

output "security_groups" {
  value = aws_instance.instance.vpc_security_group_ids
}

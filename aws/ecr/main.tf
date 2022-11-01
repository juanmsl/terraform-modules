variable "project" {}
variable "scan_on_push" {}

locals {
  tags = {
    Project    = var.project
    AWSService = "ecr"
  }
}

resource "aws_ecr_repository" "ecr" {
  name = var.project
  tags = local.tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

output "arn" {
  value = aws_ecr_repository.ecr.arn
}

output "name" {
  value = aws_ecr_repository.ecr.name
}

output "url" {
  value = aws_ecr_repository.ecr.repository_url
}
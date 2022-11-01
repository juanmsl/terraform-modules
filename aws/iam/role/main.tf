variable "project" {}
variable "environment" {}
variable "role" {}
variable "path" {
  default = "/role/"
}
variable "max_session_duration" {
  default = 43200
}
variable "principals" {
  type = map
}
variable "actions" {
  type = list
}
variable "resources" {
  type = list
}
variable "policy_arns" {
  type    = list
  default = []
}

locals {
  name = join("-", [var.project, var.environment, var.role])
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "iam"
  }
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect    = "Allow"
    actions   = var.actions
    resources = var.resources
    dynamic "principals" {
      for_each = var.principals
      content {
        type        = principals.key
        identifiers = principals.value
      }
    }
  }
}

resource "aws_iam_role" "role" {
  name                 = local.name
  assume_role_policy   = data.aws_iam_policy_document.assume_policy.json
  path                 = var.path
  max_session_duration = var.max_session_duration
  tags                 = local.tags
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.value
  role       = aws_iam_role.role.id
}

output "id" {
  value = aws_iam_role.role.id
}

output "arn" {
  value = aws_iam_role.role.arn
}

output "name" {
  value = aws_iam_role.role.name
}
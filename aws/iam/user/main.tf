variable "name" {}
variable "path" {
  default = "/user/"
}
variable "policy_arns" {
  type    = list
  default = []
}
variable "groups" {
  type    = list
  default = []
}

locals {
  tags = {
    Name       = var.name
    AWSService = "iam"
  }
}

resource "aws_iam_user" "user" {
  name = var.name
  path = var.path
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "policy" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.value
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_group_membership" "group" {
  groups = var.groups
  user   = aws_iam_user.user.name
}

output "arn" {
  value = aws_iam_user.user.arn
}

output "name" {
  value = aws_iam_user.user.name
}
variable "name" {}
variable "path" {
  default = "/group/"
}
variable "policy_arns" {
  type    = list
  default = []
}

locals {
  tags = {
    Name       = var.name
    AWSService = "iam"
  }
}

resource "aws_iam_group" "group" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "policy" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.value
  group      = aws_iam_group.group.id
}

output "id" {
  value = aws_iam_group.group.id
}

output "arn" {
  value = aws_iam_group.group.arn
}

output "name" {
  value = aws_iam_group.group.name
}
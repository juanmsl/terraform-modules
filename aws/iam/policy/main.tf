variable "project" {}
variable "environment" {}
variable "role" {}
variable "policy" {}
variable "roles" {
  type    = list
  default = null
}
variable "groups" {
  type    = list
  default = null
}
variable "users" {
  type    = list
  default = null
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

resource "aws_iam_policy" "policy" {
  name   = local.name
  policy = var.policy
  tags   = local.tags
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = local.name
  policy_arn = aws_iam_policy.policy.arn
  groups     = var.groups
  roles      = var.roles
  users      = var.users
}
variable "account" {}
variable "environment" {}
variable "registries" {
  type = list
}
variable "buckets" {
  type = list
}
variable "scan_on_push" {
  default = false
}

module "ecr" {
  source       = "../../aws/ecr"
  for_each     = toset(var.registries)
  project      = each.value
  scan_on_push = var.scan_on_push
}

data "aws_iam_policy_document" "user_policy" {
  statement {
    actions   = ["ecr:*"]
    resources = [for ecr in module.ecr : ecr.arn]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = var.buckets
  }
}

module "user" {
  source = "../../aws/iam/user"
  name   = "${var.account}-ecr"
  path   = "/system/"
}

module "user_policy" {
  source      = "../../aws/iam/policy"
  environment = var.environment
  project     = var.account
  role        = "ecr"
  users       = [module.user.name]
  policy      = data.aws_iam_policy_document.user_policy.json
}

resource "aws_iam_access_key" "access_key" {
  user = module.user.name
}

output "ecr" {
  value = {
    arns = [for ecr in module.ecr : ecr.arn]
    urls = [for ecr in module.ecr : ecr.url]
  }
}

output "credentials" {
  sensitive = true
  value     = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.access_key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.access_key.secret
  }
}

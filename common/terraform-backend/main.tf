variable "account" {}
variable "account_id" {}
variable "environment" {}
variable "region" {}
variable "read_capacity" {
  default = 1
}
variable "write_capacity" {
  default = 1
}

module "bucket" {
  source      = "../../aws/s3/bucket"
  project     = var.account
  environment = var.environment
  role        = "terraform-backend"
  versioning  = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = module.bucket.name
  acl    = "private"
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
      type        = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "kms" {
  source      = "../../aws/kms/key"
  environment = var.environment
  project     = var.account
  role        = "terraform-backend"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

module "dynamo" {
  source         = "../../aws/dynamo/table"
  project        = var.account
  environment    = var.environment
  role           = "terraform-backend"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "LockID"
  attributes     = {
    "LockID" = "S"
  }
}

output "bucket" {
  value = {
    name = module.bucket.name
    arn  = module.bucket.arn
  }
}

output "dynamo" {
  value = {
    name = module.dynamo.name
    arn  = module.dynamo.arn
    id   = module.dynamo.id
  }
}

output "kms" {
  value = {
    key_id = module.kms.key_id
    arn    = module.kms.arn
    name   = module.kms.name
  }
}

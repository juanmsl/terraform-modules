variable "project" {}
variable "environment" {}
variable "role" {}
variable "versioning" {
  default = true
}
variable "mfa_delete" {
  default = false
}
variable "sse_kms_key_id" {
  default = ""
}

locals {
  name                                 = join("-", [var.project, var.environment, var.role])
  tags                                 = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "s3"
  }
}

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "bucket" {
  bucket        = local.name
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.bucket

  versioning_configuration {
    status     = var.versioning ? "Enabled" : "Disabled"
    mfa_delete = var.mfa_delete ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse_configuration" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_kms_key_id == "" ? "AES256" : "aws:kms"
      kms_master_key_id = var.sse_kms_key_id == "" ? null : var.sse_kms_key_id
    }
  }
}

output "id" {
  value = aws_s3_bucket.bucket.id
}

output "name" {
  value = aws_s3_bucket.bucket.bucket
}

output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "regional_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "hosted_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}

output "region" {
  value = aws_s3_bucket.bucket.region
}

output "website_endpoint" {
  value = aws_s3_bucket.bucket.website_endpoint
}

output "website_domain" {
  value = aws_s3_bucket.bucket.website_domain
}
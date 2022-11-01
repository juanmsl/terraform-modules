variable "project" {}
variable "environment" {}
variable "role" {}
variable "bucket_name" {}
variable "object_key" {}
variable "content" {}
variable "content_type" {}

locals {
  tags = {
    Name        = var.object_key
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "s3"
  }
}

resource "aws_s3_bucket_object" "bucket_object" {
  bucket  = var.bucket_name
  key     = var.object_key
  content = var.content
  etag    = md5(var.content)
  tags    = local.tags
  content_type = var.content_type
}

output "id" {
  value = aws_s3_bucket_object.bucket_object.id
}

output "etag" {
  value = aws_s3_bucket_object.bucket_object.etag
}

output "version_id" {
  value = aws_s3_bucket_object.bucket_object.version_id
}
variable "project" {}
variable "environment" {}
variable "role" {}
variable "handler" {}
variable "iam_role_arn" {}
variable "runtime" {}
variable "source_file_s3" {
  type = "map"
  #  {
  #    bucket  = ""
  #    key     = ""
  #    version = ""
  #  }
}
variable "layers" {
  type    = "list"
  default = []
}
variable "environment_variables" {
  type    = "map"
  default = {}
}
variable "security_group_ids" {
  type    = "list"
  default = []
}
variable "subnet_ids" {
  type    = "list"
  default = []
}
variable "timeout" {
  default = 3
}
variable "memory_size" {
  default = 128
}

locals {
  name        = join("-", list(var.project, var.environment, var.role))
  _vpc_config = {
    security_group_ids = var.security_group_ids,
    subnet_ids         = var.subnet_ids
  }
  vpc_config  = var.security_group_ids != [] && var.subnet_ids != [] ? [local._vpc_config] : []
  tags        = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
    Role        = var.role
    AWSService  = "lambda"
  }
}

resource "aws_lambda_function" "function" {
  function_name     = local.name
  handler           = var.handler
  role              = var.iam_role_arn
  runtime           = var.runtime
  timeout           = var.timeout
  tags              = local.tags
  layers            = var.layers
  memory_size       = var.memory_size
  s3_bucket         = lookup(var.source_file_s3, "bucket")
  s3_key            = lookup(var.source_file_s3, "key")
  s3_object_version = lookup(var.source_file_s3, "version")

  dynamic "environment" {
    for_each = [var.environment_variables]
    content {
      variables = environment.value
    }
  }

  dynamic "vpc_config" {
    for_each = local.vpc_config
    content {
      security_group_ids = lookup(vpc_config.value, "security_group_ids")
      subnet_ids         = lookup(vpc_config.value, "subnet_ids")
    }
  }
}

output "arn" {
  value = aws_lambda_function.function.arn
}

output "name" {
  value = aws_lambda_function.function.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}
variable "project" {}
variable "environment" {}
variable "role" {}
variable "hash_key" {}
variable "range_key" {
  default = null
}
variable "read_capacity" {}
variable "write_capacity" {}
variable "stream_enabled" {
  default = false
}
variable "stream_view_type" {
  default = ""
}
variable "attributes" {
  type = map
  # {
  #   "timestamp": "S",
  #   "customer_id": "N",
  # }
}
variable "global_secondary_indexes" {
  type    = list
  default = []
}
variable "local_secondary_indexes" {
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
    AWSService  = "dynamo"
  }
}

resource "aws_dynamodb_table" "table" {
  name             = local.name
  hash_key         = var.hash_key
  range_key        = var.range_key
  read_capacity    = var.read_capacity
  write_capacity   = var.write_capacity
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type
  tags             = local.tags

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = toset(var.global_secondary_indexes)
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      projection_type    = global_secondary_index.value.projection_type
      write_capacity     = var.write_capacity
      read_capacity      = var.read_capacity
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  dynamic "local_secondary_index" {
    for_each = toset(var.local_secondary_indexes)
    content {
      range_key          = local_secondary_index.value.range_key
      name               = local_secondary_index.value.name
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.non_key_attributes
    }
  }

  point_in_time_recovery {
    enabled = true
  }
}

output "id" {
  value = aws_dynamodb_table.table.id
}

output "arn" {
  value = aws_dynamodb_table.table.arn
}

output "name" {
  value = aws_dynamodb_table.table.name
}
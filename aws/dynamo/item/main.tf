variable "dynamo_table_name" {}
variable "item" {
  type = map
}

data "aws_dynamodb_table" "table" {
  name = var.dynamo_table_name
}

resource "aws_dynamodb_table_item" "item" {
  hash_key   = data.aws_dynamodb_table.table.hash_key
  range_key  = data.aws_dynamodb_table.table.range_key
  item       = jsonencode(var.item)
  table_name = var.dynamo_table_name
}
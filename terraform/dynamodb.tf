resource "aws_dynamodb_table" "adv-database-logs" {
  name           = "adv-db-msgs"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "locationHash"
  range_key      = "createdAt"

  attribute {
    name = "locationHash"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {}
}

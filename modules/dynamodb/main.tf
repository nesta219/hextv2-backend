resource "aws_dynamodb_table" "scores" {
  name         = "hextv2-scores-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "playerId"
  range_key    = "timestamp"

  attribute {
    name = "playerId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "scorePartition"
    type = "S"
  }

  attribute {
    name = "score"
    type = "N"
  }

  global_secondary_index {
    name            = "TopScoresIndex"
    hash_key        = "scorePartition"
    range_key       = "score"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }
}

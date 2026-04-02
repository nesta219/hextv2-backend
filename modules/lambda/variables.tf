variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB scores table name"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB scores table ARN"
  type        = string
}

variable "dynamodb_gsi_name" {
  description = "DynamoDB GSI name for top scores"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for scenes"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for scenes"
  type        = string
}

variable "s3_manifest_key" {
  description = "S3 key for the scenes manifest"
  type        = string
}

variable "lambdas_source_dir" {
  description = "Path to the lambdas source directory"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "manifest_source" {
  description = "Path to the seed scenes manifest JSON file"
  type        = string
}

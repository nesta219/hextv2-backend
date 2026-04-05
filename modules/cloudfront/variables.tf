variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for scene content"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for scene content"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  type        = string
}

variable "cdn_subdomain" {
  description = "CDN subdomain (e.g., cdn.dev.hextv2)"
  type        = string
}

variable "domain" {
  description = "Root domain (e.g., mikenesta.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

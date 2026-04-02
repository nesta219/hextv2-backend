variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "api_subdomain" {
  description = "API subdomain prefix (e.g., api.dev.hextv2)"
  type        = string
}

variable "domain" {
  description = "Root domain (e.g., mikenesta.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the root domain"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway HTTP API ID"
  type        = string
}

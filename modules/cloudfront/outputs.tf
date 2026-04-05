output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.scenes.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.scenes.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.scenes.domain_name
}

output "cdn_fqdn" {
  description = "Custom domain FQDN for the CDN"
  value       = local.fqdn
}

output "cdn_url" {
  description = "Full HTTPS URL for the CDN"
  value       = "https://${local.fqdn}"
}

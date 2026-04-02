output "certificate_arn" {
  value = aws_acm_certificate.api.arn
}

output "custom_domain_name" {
  value = aws_apigatewayv2_domain_name.api.domain_name
}

output "api_fqdn" {
  value = local.fqdn
}

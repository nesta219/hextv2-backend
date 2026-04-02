output "identity_pool_id" {
  value = aws_cognito_identity_pool.main.id
}

output "unauthenticated_role_arn" {
  value = aws_iam_role.cognito_unauth.arn
}

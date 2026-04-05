output "bucket_name" {
  value = aws_s3_bucket.scenes.id
}

output "bucket_arn" {
  value = aws_s3_bucket.scenes.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.scenes.bucket_regional_domain_name
}

output "manifest_key" {
  value = aws_s3_object.manifest.key
}

output "editor_upload_user_name" {
  description = "IAM user name for editor bundle uploads"
  value       = aws_iam_user.editor_upload.name
}

output "editor_upload_user_arn" {
  description = "IAM user ARN for editor bundle uploads"
  value       = aws_iam_user.editor_upload.arn
}

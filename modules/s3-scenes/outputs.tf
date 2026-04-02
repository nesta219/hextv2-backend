output "bucket_name" {
  value = aws_s3_bucket.scenes.id
}

output "bucket_arn" {
  value = aws_s3_bucket.scenes.arn
}

output "manifest_key" {
  value = aws_s3_object.manifest.key
}

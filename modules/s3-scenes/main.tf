resource "aws_s3_bucket" "scenes" {
  bucket = "hextv2-scenes-${var.environment}-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "scenes" {
  bucket = aws_s3_bucket.scenes.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "scenes" {
  bucket = aws_s3_bucket.scenes.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "scenes" {
  bucket = aws_s3_bucket.scenes.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.scenes.id
  key          = "manifests/scenes.json"
  source       = var.manifest_source
  content_type = "application/json"
  etag         = filemd5(var.manifest_source)
}

# --- IAM User for Editor Uploads ---

resource "aws_iam_user" "editor_upload" {
  name = "hextv2-editor-upload-${var.environment}"
}

resource "aws_iam_user_policy" "editor_upload" {
  name = "hextv2-editor-upload-policy-${var.environment}"
  user = aws_iam_user.editor_upload.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBundleUpload"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.scenes.arn,
          "${aws_s3_bucket.scenes.arn}/*"
        ]
      },
      {
        Sid    = "AllowCloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      }
    ]
  })
}

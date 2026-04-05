locals {
  fqdn = "${var.cdn_subdomain}.${var.domain}"
}

# --- Origin Access Control ---

resource "aws_cloudfront_origin_access_control" "scenes" {
  name                              = "hextv2-scenes-oac-${var.environment}"
  description                       = "OAC for HextV2 scenes S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- ACM Certificate (must be us-east-1 for CloudFront) ---

resource "aws_acm_certificate" "cdn" {
  domain_name       = local.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cdn_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "cdn" {
  certificate_arn         = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [for record in aws_route53_record.cdn_cert_validation : record.fqdn]
}

# --- CloudFront Distribution ---

resource "aws_cloudfront_distribution" "scenes" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "HextV2 scene content CDN (${var.environment})"
  default_root_object = ""
  price_class         = "PriceClass_100" # US, Canada, Europe

  aliases = [local.fqdn]

  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "s3-scenes"
    origin_access_control_id = aws_cloudfront_origin_access_control.scenes.id
  }

  # Manifest files: short TTL so updates propagate quickly
  ordered_cache_behavior {
    path_pattern     = "manifests/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-scenes"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300   # 5 minutes
    max_ttl                = 600   # 10 minutes
    compress               = true
  }

  # Default: bundle files (immutable by hash, long cache)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-scenes"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 2592000  # 30 days
    max_ttl                = 31536000 # 365 days
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cdn.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# --- S3 Bucket Policy (allow CloudFront OAC) ---

resource "aws_s3_bucket_policy" "scenes_cloudfront" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.scenes.arn
          }
        }
      }
    ]
  })
}

# --- Route53 DNS Record ---

resource "aws_route53_record" "cdn" {
  name    = local.fqdn
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_cloudfront_distribution.scenes.domain_name
    zone_id                = aws_cloudfront_distribution.scenes.hosted_zone_id
    evaluate_target_health = false
  }
}

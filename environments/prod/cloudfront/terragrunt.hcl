include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/cloudfront"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "s3_scenes" {
  config_path = "../s3-scenes"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    bucket_name                 = "mock-bucket"
    bucket_arn                  = "arn:aws:s3:::mock-bucket"
    bucket_regional_domain_name = "mock-bucket.s3.us-east-1.amazonaws.com"
    manifest_key                = "manifests/scenes.json"
    editor_upload_user_name     = "mock-user"
    editor_upload_user_arn      = "arn:aws:iam::000000000000:user/mock-user"
  }
}

inputs = {
  environment                    = local.env.locals.environment
  s3_bucket_name                 = dependency.s3_scenes.outputs.bucket_name
  s3_bucket_arn                  = dependency.s3_scenes.outputs.bucket_arn
  s3_bucket_regional_domain_name = dependency.s3_scenes.outputs.bucket_regional_domain_name
  cdn_subdomain                  = local.env.locals.cdn_subdomain
  domain                         = local.env.locals.domain
  hosted_zone_id                 = local.env.locals.hosted_zone_id
}

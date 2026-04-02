include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/lambda"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "dynamodb" {
  config_path = "../dynamodb"

  mock_outputs = {
    table_name = "mock-table"
    table_arn  = "arn:aws:dynamodb:us-east-1:000000000000:table/mock-table"
    gsi_name   = "TopScoresIndex"
  }
}

dependency "s3_scenes" {
  config_path = "../s3-scenes"

  mock_outputs = {
    bucket_name  = "mock-bucket"
    bucket_arn   = "arn:aws:s3:::mock-bucket"
    manifest_key = "manifests/scenes.json"
  }
}

inputs = {
  environment         = local.env.locals.environment
  dynamodb_table_name = dependency.dynamodb.outputs.table_name
  dynamodb_table_arn  = dependency.dynamodb.outputs.table_arn
  dynamodb_gsi_name   = dependency.dynamodb.outputs.gsi_name
  s3_bucket_name      = dependency.s3_scenes.outputs.bucket_name
  s3_bucket_arn       = dependency.s3_scenes.outputs.bucket_arn
  s3_manifest_key     = dependency.s3_scenes.outputs.manifest_key
  lambdas_source_dir  = "${get_repo_root()}/lambdas"
}

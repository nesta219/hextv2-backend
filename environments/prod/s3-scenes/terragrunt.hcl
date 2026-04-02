include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/s3-scenes"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  environment     = local.env.locals.environment
  account_id      = local.env.locals.account_id
  manifest_source = "${get_repo_root()}/seed-data/scenes-manifest.json"
}

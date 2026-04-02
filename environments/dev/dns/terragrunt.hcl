include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/dns"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "api_gateway" {
  config_path = "../api-gateway"

  mock_outputs = {
    api_id = "mock-api-id"
  }
}

inputs = {
  environment    = local.env.locals.environment
  api_subdomain  = local.env.locals.api_subdomain
  domain         = local.env.locals.domain
  hosted_zone_id = local.env.locals.hosted_zone_id
  api_gateway_id = dependency.api_gateway.outputs.api_id
}

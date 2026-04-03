include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/api-gateway"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "lambda" {
  config_path = "../lambda"

  mock_outputs = {
    submit_score_invoke_arn          = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:mock/invocations"
    submit_score_function_name       = "mock-submit-score"
    get_top_scores_invoke_arn        = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:mock/invocations"
    get_top_scores_function_name     = "mock-get-top-scores"
    get_player_scores_invoke_arn     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:mock/invocations"
    get_player_scores_function_name  = "mock-get-player-scores"
    get_scenes_invoke_arn            = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:mock/invocations"
    get_scenes_function_name         = "mock-get-scenes"
  }
}

inputs = {
  environment                  = local.env.locals.environment
  submit_score_invoke_arn      = dependency.lambda.outputs.submit_score_invoke_arn
  submit_score_function_name   = dependency.lambda.outputs.submit_score_function_name
  get_top_scores_invoke_arn    = dependency.lambda.outputs.get_top_scores_invoke_arn
  get_top_scores_function_name = dependency.lambda.outputs.get_top_scores_function_name
  get_player_scores_invoke_arn     = dependency.lambda.outputs.get_player_scores_invoke_arn
  get_player_scores_function_name  = dependency.lambda.outputs.get_player_scores_function_name
  get_scenes_invoke_arn            = dependency.lambda.outputs.get_scenes_invoke_arn
  get_scenes_function_name         = dependency.lambda.outputs.get_scenes_function_name
}

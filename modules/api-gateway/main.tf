# --- API ---

resource "aws_apigatewayv2_api" "main" {
  name          = "hextv2-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "X-Player-Id"]
    max_age       = 3600
  }
}

# --- CloudWatch Log Group ---

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/hextv2-${var.environment}"
  retention_in_days = 14
}

# --- Stage ---

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 100
  }
}

# --- Integrations ---

resource "aws_apigatewayv2_integration" "submit_score" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.submit_score_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_top_scores" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.get_top_scores_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_scenes" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.get_scenes_invoke_arn
  payload_format_version = "2.0"
}

# --- Routes ---

resource "aws_apigatewayv2_route" "post_scores" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /scores"
  target    = "integrations/${aws_apigatewayv2_integration.submit_score.id}"
}

resource "aws_apigatewayv2_route" "get_top_scores" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /scores/top"
  target    = "integrations/${aws_apigatewayv2_integration.get_top_scores.id}"
}

resource "aws_apigatewayv2_route" "get_scenes" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /scenes"
  target    = "integrations/${aws_apigatewayv2_integration.get_scenes.id}"
}

# --- Lambda Permissions ---

resource "aws_lambda_permission" "submit_score" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.submit_score_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_top_scores" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.get_top_scores_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_scenes" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.get_scenes_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

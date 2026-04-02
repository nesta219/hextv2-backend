# --- IAM Role ---

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "hextv2-lambda-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    sid    = "DynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
    ]
    resources = [
      var.dynamodb_table_arn,
      "${var.dynamodb_table_arn}/index/*",
    ]
  }

  statement {
    sid    = "S3Read"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:HeadObject",
    ]
    resources = [
      "${var.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "hextv2-lambda-permissions-${var.environment}"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

# --- Lambda Packages ---

data "archive_file" "submit_score" {
  type        = "zip"
  source_dir  = "${var.lambdas_source_dir}/submit_score"
  output_path = "${var.lambdas_source_dir}/../.build/submit_score.zip"
}

data "archive_file" "get_top_scores" {
  type        = "zip"
  source_dir  = "${var.lambdas_source_dir}/get_top_scores"
  output_path = "${var.lambdas_source_dir}/../.build/get_top_scores.zip"
}

data "archive_file" "get_scenes" {
  type        = "zip"
  source_dir  = "${var.lambdas_source_dir}/get_scenes"
  output_path = "${var.lambdas_source_dir}/../.build/get_scenes.zip"
}

# --- Lambda Functions ---

resource "aws_lambda_function" "submit_score" {
  function_name    = "hextv2-submit-score-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 10
  filename         = data.archive_file.submit_score.output_path
  source_code_hash = data.archive_file.submit_score.output_base64sha256

  environment {
    variables = {
      SCORES_TABLE = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "get_top_scores" {
  function_name    = "hextv2-get-top-scores-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 10
  filename         = data.archive_file.get_top_scores.output_path
  source_code_hash = data.archive_file.get_top_scores.output_base64sha256

  environment {
    variables = {
      SCORES_TABLE = var.dynamodb_table_name
      GSI_NAME     = var.dynamodb_gsi_name
    }
  }
}

resource "aws_lambda_function" "get_scenes" {
  function_name    = "hextv2-get-scenes-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 10
  filename         = data.archive_file.get_scenes.output_path
  source_code_hash = data.archive_file.get_scenes.output_base64sha256

  environment {
    variables = {
      SCENES_BUCKET = var.s3_bucket_name
      MANIFEST_KEY  = var.s3_manifest_key
    }
  }
}

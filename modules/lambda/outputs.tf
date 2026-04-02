output "submit_score_invoke_arn" {
  value = aws_lambda_function.submit_score.invoke_arn
}

output "submit_score_function_name" {
  value = aws_lambda_function.submit_score.function_name
}

output "get_top_scores_invoke_arn" {
  value = aws_lambda_function.get_top_scores.invoke_arn
}

output "get_top_scores_function_name" {
  value = aws_lambda_function.get_top_scores.function_name
}

output "get_scenes_invoke_arn" {
  value = aws_lambda_function.get_scenes.invoke_arn
}

output "get_scenes_function_name" {
  value = aws_lambda_function.get_scenes.function_name
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "submit_score_invoke_arn" {
  type = string
}

variable "submit_score_function_name" {
  type = string
}

variable "get_top_scores_invoke_arn" {
  type = string
}

variable "get_top_scores_function_name" {
  type = string
}

variable "get_player_scores_invoke_arn" {
  type = string
}

variable "get_player_scores_function_name" {
  type = string
}

variable "get_scenes_invoke_arn" {
  type = string
}

variable "get_scenes_function_name" {
  type = string
}

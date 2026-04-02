data "aws_region" "current" {}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "hextv2-${var.environment}"
  allow_unauthenticated_identities = true
  allow_classic_flow               = true
}

data "aws_iam_policy_document" "cognito_unauth_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "cognito_unauth" {
  name               = "hextv2-cognito-unauth-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cognito_unauth_assume.json
}

data "aws_iam_policy_document" "cognito_unauth_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-identity:GetId",
      "cognito-identity:GetCredentialsForIdentity",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cognito_unauth" {
  name   = "hextv2-cognito-unauth-policy-${var.environment}"
  role   = aws_iam_role.cognito_unauth.id
  policy = data.aws_iam_policy_document.cognito_unauth_policy.json
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "unauthenticated" = aws_iam_role.cognito_unauth.arn
  }
}

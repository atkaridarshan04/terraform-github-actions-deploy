#######################################
# 1️⃣  GitHub OIDC Provider Setup
#######################################

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

#######################################
# 2️⃣ IAM Role for GitHub Actions
#######################################

data "aws_iam_policy_document" "oidc_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated" # an external identity provider (OIDC)
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_org}/${local.github_repo}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = local.oidc_role_name
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role.json
  description        = "Role for GitHub Actions to assume via OIDC to run Terraform"

  tags = {
    Project = local.github_repo
  }
}

# Attach permissions policy to the role
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "oidc_role_arn" {
  description = "ARN of IAM role that GitHub Actions will assume"
  value       = aws_iam_role.github_actions_role.arn
}
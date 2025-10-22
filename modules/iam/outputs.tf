# modules\iam\outputs.tf

output "github_actions_oidc_role_arn" {
  value       = aws_iam_role.github_actions_oidc.arn
  description = "IAM Role ARN assumed by GitHub Actions via OIDC"
}
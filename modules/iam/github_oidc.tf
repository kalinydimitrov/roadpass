data "aws_caller_identity" "current" {}

# GitHub OIDC provider (should exist exists in AWS already)
# data "aws_iam_openid_connect_provider" "github" {
#   arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
# }

#  Create Github’s Open ID Connect (OIDC) provider 
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


resource "aws_iam_role" "github_actions_oidc" {
  name = "stg-github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Restriction to my repo only !!!
            "token.actions.githubusercontent.com:sub" = "repo:${var.GITHUB_USERNAME}/${var.GITHUB_REPO_NAME}:*"
          }
        }
      }
    ]
  })
}

# Least-privilege EKS + deployment permissions
resource "aws_iam_role_policy_attachment" "github_actions_eks" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "github_actions_helm" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# This will allow kubectl/helm to interact with cluster
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

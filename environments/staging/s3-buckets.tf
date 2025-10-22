# environments\staging\s3-buckets.tf

# S3 bucket for SSM session logs

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3_ssm_session_logs" {
  bucket        = "stg-ssm-session-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name        = "stg-ssm-session-logs"
    Environment = "staging"
  }
}


resource "aws_iam_role_policy" "ssm_ec2_s3_access" {
  name = "${var.prefix}-EC2-SSM-S3-Access"
  role = aws_iam_role.ssm_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:GetEncryptionConfiguration",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_ssm_session_logs.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_ssm_session_logs.bucket}/*"
        ]
      }
    ]
  })
}


# stored logs will be deleted after 365 days
resource "aws_s3_bucket_lifecycle_configuration" "ssm_logs_lifecycle" {
  bucket = aws_s3_bucket.s3_ssm_session_logs.id

  rule {
    id     = "expire-old-ssm-logs"
    status = "Enabled"

    expiration {
      days = 365
    }

    filter {}
  }
}

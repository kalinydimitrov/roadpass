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

resource "aws_s3_bucket_versioning" "s3_ssm_session_logs" {
  bucket = aws_s3_bucket.s3_ssm_session_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_ssm_session_logs" {
  bucket = aws_s3_bucket.s3_ssm_session_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
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

# environments\staging\ssm-logs-to-s3.tf

# Enable SSM session logging to S3 bucket 
# SSM Session Manager logging configuration

# resource "aws_ssm_document" "session_manager_logging" {
#   name          = "SSM-SessionManagerLogging"
#   document_type = "Session"
#   document_format = "JSON"

#   content = jsonencode({
#     schemaVersion = "1.0"
#     description   = "Send SSM session logs to S3 bucket"
#     sessionType   = "Standard_Stream"
#     inputs = {
#       s3BucketName = aws_s3_bucket.ssm_session_logs.bucket
#       s3KeyPrefix  = "logs/"
#       cloudWatchLogGroupName = ""
#       cloudWatchEncryptionEnabled = false
#       s3EncryptionEnabled = true
#     }
#   })
# }

# # Attach the SSM document to the SSM role
# resource "aws_ssm_association" "ssm_session_logging_association" {
#   name            = aws_ssm_document.session_manager_logging.name
#   instance_id     = aws_instance.ssm_test.id
# }

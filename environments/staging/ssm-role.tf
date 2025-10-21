# environments/staging/ssm-role.tf

# bellow is the ssm role and instance profile for ec2 instances to communicate with ssm
resource "aws_iam_role" "ssm_ec2_role" {
  name = "stg-EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "staging"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_policy" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_ec2_instance_profile" {
  name = "stg-EC2-SSM-Profile"
  role = aws_iam_role.ssm_ec2_role.name
}

output "ssm_instance_profile_name" {
  value = aws_iam_instance_profile.ssm_ec2_instance_profile.name
}

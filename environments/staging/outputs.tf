# root/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.staging_vpc.vpc_id
}

output "public_subnets" {
  description = "values of public subnet IDs"
  value       = module.staging_vpc.public_subnets
}

output "private_subnets" {
  description = "values of private subnet IDs"
  value       = module.staging_vpc.private_subnets
}

output "nat_gateways" {
  description = "IDs of the NAT Gateways"
  value       = module.staging_vpc.nat_gateways
}

output "ssm_ec2_role_instance_profile_name" {
  description = "The name of the SSM EC2 Instance Profile"
  value       = aws_iam_instance_profile.ssm_ec2_instance_profile.name

}

output "ssm_test_instance_id" {
  description = "The ID of the EC2 instance used for SSM testing"
  value       = aws_instance.ssm_test.id
}

output "ssm_session_logs_bucket_name" {
  description = "S3 bucket name used for SSM session logs"
  value       = aws_s3_bucket.s3_ssm_session_logs.bucket
}

# --- EKS Cluster OIDC Provider URL Output ---
output "eks_oidc_provider_url" {
  description = "The OIDC provider URL for the EKS cluster"
  value       = aws_cloudformation_stack.eks_cluster.outputs["ClusterOpenIdConnectIssuerUrl"]
}

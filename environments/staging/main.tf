# root/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# S3 backend for Terraform state
# terraform {
#   backend "s3" {
#     bucket = "roadpass-terraform-state"
#     key    = "staging/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

module "staging_vpc" {
  source      = "../../modules/vpc"
  environment = "staging"
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  az_count    = 2

  tags = {
    Environment = "staging"
    Project     = "roadpass"
  }
}

# --- Create a Test EC2 Instance (Private Subnet + SSM Access) ---
resource "aws_instance" "ssm_test" {
  ami                         = var.test_instance_ami
  instance_type               = "t3.micro"
  subnet_id                   = module.staging_vpc.private_subnets[0] # place in first private subnet
  iam_instance_profile        = aws_iam_instance_profile.ssm_ec2_instance_profile.name
  associate_public_ip_address = false

  tags = {
    Name        = "stg-ssm-test"
    Environment = "staging"
  }
}

# --- Enable SSM session logging to S3 bucket ---
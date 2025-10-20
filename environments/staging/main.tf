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
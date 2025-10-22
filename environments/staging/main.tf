# root/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
# null provider added according to:
# https://registry.terraform.io/providers/hashicorp/null/latest

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

provider "helm" {
  # Configuration options
}

# --- helm provirer required for helm charts deployment ---



# Set S3 backend for Terraform state:
# !!! this S3 bucket must be pre-created. Execute bellow: !!!
# aws s3api create-bucket \
#   --bucket roadpass-terraform-state-1 \
#   --region us-east-1


terraform {
  backend "s3" {
    bucket = "roadpass-terraform-state-1"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- VPC Module called here ---
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

module "github" {
  source           = "../../modules/iam"
  GITHUB_USERNAME  = var.GITHUB_USERNAME
  GITHUB_REPO_NAME = var.GITHUB_REPO_NAME

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

# !!! Bellow Not working ATM - eks:CreateCluster action is not authorized for iam user !!!
# !!! uncommnet once eks:CreateCluster is enabled

# Create EKS Cluster using CloudFormation Stack
# This will provision EKS cluster in the existing VPC created above
# resource "aws_cloudformation_stack" "eks_cluster" {
#   name          = "stg-eks-cluster"
#   template_body = file("${path.module}/eks-cluster-existing-vpc.yaml")
#   capabilities  = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

#   parameters = {
#     ClusterName      = "stg-eks-cluster"
#     VpcId            = module.staging_vpc.vpc_id
#     PrivateSubnet1Id = module.staging_vpc.private_subnets[0]
#     PrivateSubnet2Id = module.staging_vpc.private_subnets[1]
#   }
# }


# This will provision nginx server using helm chart from \helm\nginx-server\Chart.yaml
# resource "helm_release" "nginx_server" {
#   name             = "nginx-server"
#   chart            = "${path.module}/helm/nginx-server"
#   namespace        = "webapps"
#   create_namespace = true
#   values           = [file("${path.module}/helm/nginx-server/values.yaml")]
# }

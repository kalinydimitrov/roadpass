# root/variables.tf

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

# Find a valid AMI in my region (us-east-1) - go to:
# https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AMICatalog:
# available images:
# - Amazon Linux 2023 kernel-6.1 AMI with ami-0341d95f75f311023 #<< will use this one
# - Amazon Linux 2023 kernel-6.12 AMI with ami-0018b373aba829819

variable "test_instance_ami" {
  description = "AMI ID for the test EC2 instance"
  type        = string
  default     = "ami-0341d95f75f311023" # Amazon Linux 2 in "us-east-1"
}


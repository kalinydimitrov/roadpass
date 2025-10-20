# modules/vpc/locals.tf

locals {

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  name_prefix = "${var.prefix}-${var.environment}"

  # using slice() to take only the first 2 availability zones as var.az_count = 2
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  # expected output: ["us-east-2a", "us-east-2b"]


# Subnet CIDR calculations. We need one public subnet per Availability Zone !!!
  # /16 split into /20s → 16 subnets
  # cidrsubnet(prefix, newbits, netnum)
  # prefix: "172.16.0.0/16"
  # newbits: extra bits to add to the subnet mask - here we add 4 bits to go from /16 to /20
  # netnum: which subnet index to take (e.g. 0, 1, 2, ...) - we need 2 pub subnets, one per AZ

  # Public subnets:
  public_subnets = [
    for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)
  ]
  # expected output:
  # cidrsubnet("172.16.0.0/16", 4, 0) = 172.16.0.0/20
  # cidrsubnet("172.16.0.0/16", 4, 1) = 172.16.16.0/20

  # Private subnets:
  private_subnets = [
    for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + length(local.azs))
  ]
  # i + length(local.azs) - start numbering after the public subnets
  # expected output:
  # cidrsubnet("172.16.0.0/16", 4, 2) → 172.16.32.0/20
  # cidrsubnet("172.16.0.0/16", 4, 3) → 172.16.48.0/20

}
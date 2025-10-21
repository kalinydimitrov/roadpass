# modules/vpc/main.tf

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

# Create a VPC
resource "aws_vpc" "roadpass_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.common_tags
}


# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.roadpass_vpc.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-public-${local.azs[count.index]}"
    Tier = "public"
  })
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.roadpass_vpc.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(var.tags, {
    Name = "${var.prefix}-private-${local.azs[count.index]}"
    Tier = "private"
  })
}

# Create an Internet Gateway
resource "aws_internet_gateway" "roadpass_igw" {
  vpc_id = aws_vpc.roadpass_vpc.id
  tags   = merge(var.tags, { Name = "${var.prefix}-igw" })
}

# Create NAT 
resource "aws_eip" "roadpass-nat" {
  for_each = toset(local.azs)
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.prefix}-eip-${each.key}" })
}

# Create one NAT Gateway per Availability Zone
resource "aws_nat_gateway" "roadpass-natgw" {
  for_each       = toset(local.azs)
  allocation_id  = aws_eip.roadpass-nat[each.key].id
  subnet_id      = aws_subnet.public[index(local.azs, each.key)].id
  tags           = merge(var.tags, { Name = "${var.prefix}-natgw-${each.key}" })
  depends_on     = [aws_internet_gateway.roadpass_igw]
}

# ----- Routes -----

# --- Public Subnets ---
# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.roadpass_vpc.id
  tags   = merge(var.tags, { Name = "${var.prefix}-public-rt" })
}

# Create Route to Internet Gateway in Public Route Table
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.roadpass_igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private Subnets ---
# Create Private Route Table
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.roadpass_vpc.id
  tags   = merge(var.tags, { Name = "${var.prefix}-private-rt-${local.azs[count.index]}" })
}

# Create Route to Internet Gateway in Private Route Table
resource "aws_route" "private_nat" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.roadpass-natgw[local.azs[count.index]].id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ----- VPC Endpoints -----

# SG for vpc endpoints
resource "aws_security_group" "vpc-ep-sg" {
  name        = "${var.prefix}-vpc-ep-sg"
  vpc_id      = aws_vpc.roadpass_vpc.id
  description = "Allow HTTPS for VPC endpoints"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.prefix}-vpc-ep-sg" })
}

# --- SSM VPC Endpoints ---
# SSM communication flows through this endpoint types:
# com.amazonaws.${region}.ssm	        AWS Systems Manager	            Used for control-plane operations like sending commands and receiving configuration.
# com.amazonaws.${region}.ssmmessages	AWS Systems Manager Messages	Handles Session Manager data channels (real-time I/O traffic during an SSM session).
# com.amazonaws.${region}.ec2messages	EC2 Messages	                Required for the SSM Agent to communicate back with the SSM control service (heartbeats, responses, etc.).
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.roadpass_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc-ep-sg.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "${var.prefix}-ssm-endpoint" })

}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.roadpass_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc-ep-sg.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "${var.prefix}-ssmmessages-endpoint" })

}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.roadpass_vpc.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc-ep-sg.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "${var.prefix}-ec2messages-endpoint" })
  
}

# Gateway endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.roadpass_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  tags              = merge(var.tags, { Name = "${var.prefix}-s3-endpoint" })
}
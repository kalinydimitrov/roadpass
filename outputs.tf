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
# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.roadpass_vpc.id
}

output "public_subnets" {
  description = "values of public subnet IDs"
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "values of private subnet IDs"
  value = aws_subnet.private[*].id
}

output "nat_gateways" {
  description = "IDs of the NAT Gateways"
  value = [for k, v in aws_nat_gateway.roadpass-natgw : v.id]
}
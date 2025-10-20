# modules/vpc/data.tf

# Availability Zones - Fetching the list of available availability zones in the specified region
data "aws_availability_zones" "available" { state = "available" }
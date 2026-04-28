# -----------------------------------------------
# VPC ID
# Used by EC2, ECS, RDS modules to place
# resources inside this VPC
# -----------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# -----------------------------------------------
# PUBLIC SUBNET IDS
# Used by load balancers and bastion hosts
# that require public internet access
# -----------------------------------------------
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# -----------------------------------------------
# PRIVATE SUBNET IDS
# Used by EC2, ECS, RDS that should not be
# directly accessible from the internet
# -----------------------------------------------
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# -----------------------------------------------
# PUBLIC ROUTE TABLE ID
# Useful if other modules need to add routes
# e.g. VPN connections or VPC peering
# -----------------------------------------------
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE ID
# Useful if other modules need to add a
# NAT gateway route for outbound internet access
# -----------------------------------------------
output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
# -----------------------------------------------
# VPC ID
# Used by EC2, ECS, RDS and peering modules
# -----------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# -----------------------------------------------
# PUBLIC SUBNET IDS
# Used by load balancers and bastion hosts
# -----------------------------------------------
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# -----------------------------------------------
# PRIVATE SUBNET IDS
# Used by EC2, ECS, RDS resources
# -----------------------------------------------
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# -----------------------------------------------
# PUBLIC ROUTE TABLE ID
# Used if other modules need to add routes
# -----------------------------------------------
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE IDS - LIST
# Returns all private route table IDs as a list
# Used by peering module to add routes per AZ
# -----------------------------------------------
output "private_route_table_ids" {
  description = "IDs of all private route tables one per AZ"
  value       = aws_route_table.private[*].id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE ID - AZ A
# Used by peering module for intra-AZ routing
# -----------------------------------------------
output "private_route_table_az_a_id" {
  description = "ID of the AZ-a private route table"
  value       = aws_route_table.private[0].id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE ID - AZ B
# Used by peering module for intra-AZ routing
# -----------------------------------------------
output "private_route_table_az_b_id" {
  description = "ID of the AZ-b private route table"
  value       = aws_route_table.private[1].id
}
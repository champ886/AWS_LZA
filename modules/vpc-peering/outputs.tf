# -----------------------------------------------
# PEERING CONNECTION ID
# Useful for referencing in security group rules
# -----------------------------------------------
output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.main.id
}

# -----------------------------------------------
# PEERING STATUS
# Shows whether peering is active
# -----------------------------------------------
output "peering_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection_accepter.main.accept_status
}
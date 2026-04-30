# -----------------------------------------------
# PROVIDER REQUIREMENTS
# Peering needs providers for both accounts
# as the connection spans two AWS accounts
# -----------------------------------------------
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.requester, aws.accepter]
    }
  }
}

# -----------------------------------------------
# VPC PEERING CONNECTION REQUEST
# Initiated from the requester account (workload)
# pointing to the accepter account (security)
# auto_accept must be false on requester side
# -----------------------------------------------
resource "aws_vpc_peering_connection" "main" {
  provider      = aws.requester
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = var.accepter_account_id
  peer_region   = var.aws_region
  auto_accept   = false

  tags = {
    Name        = "${var.environment}-${var.peering_name}-peering"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# VPC PEERING CONNECTION ACCEPTER
# Automatically accepts the peering request
# from the accepter account (security)
# Safe to auto accept as both accounts are
# in the same AWS Organization and region
# -----------------------------------------------
resource "aws_vpc_peering_connection_accepter" "main" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = true

  tags = {
    Name        = "${var.environment}-${var.peering_name}-peering"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PEERING OPTIONS - REQUESTER
# Enables DNS resolution from requester VPC
# so hostnames in security VPC resolve correctly
# from within the workload VPC
# Must be applied after accepter is active
# -----------------------------------------------
resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.main.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# -----------------------------------------------
# PEERING OPTIONS - ACCEPTER
# Enables DNS resolution from accepter VPC
# so hostnames in workload VPC resolve correctly
# from within the security VPC
# -----------------------------------------------
resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.main.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# -----------------------------------------------
# REQUESTER PRIVATE ROUTE - AZ A
# Adds route in AZ-a private route table of
# requester VPC pointing to accepter VPC CIDR
# via the peering connection
# -----------------------------------------------
resource "aws_route" "requester_to_accepter_az_a" {
  provider                  = aws.requester
  route_table_id            = var.requester_route_table_az_a_id
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# -----------------------------------------------
# REQUESTER PRIVATE ROUTE - AZ B
# Adds route in AZ-b private route table of
# requester VPC pointing to accepter VPC CIDR
# -----------------------------------------------
resource "aws_route" "requester_to_accepter_az_b" {
  provider                  = aws.requester
  route_table_id            = var.requester_route_table_az_b_id
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# -----------------------------------------------
# ACCEPTER PRIVATE ROUTE - AZ A
# Adds route in AZ-a private route table of
# accepter (security) VPC pointing back to
# requester VPC CIDR via peering connection
# -----------------------------------------------
resource "aws_route" "accepter_to_requester_az_a" {
  provider                  = aws.accepter
  route_table_id            = var.accepter_route_table_az_a_id
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}

# -----------------------------------------------
# ACCEPTER PRIVATE ROUTE - AZ B
# Adds route in AZ-b private route table of
# accepter (security) VPC pointing back to
# requester VPC CIDR
# -----------------------------------------------
resource "aws_route" "accepter_to_requester_az_b" {
  provider                  = aws.accepter
  route_table_id            = var.accepter_route_table_az_b_id
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  depends_on = [aws_vpc_peering_connection_accepter.main]
}
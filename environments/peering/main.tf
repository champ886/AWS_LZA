# -----------------------------------------------
# DATA SOURCES - DEV WORKLOAD VPC
# Reads existing dev VPC deployed by dev/vpc
# -----------------------------------------------
data "aws_vpc" "dev_workload" {
  provider   = aws.dev_workload
  cidr_block = var.dev_workload_vpc_cidr
}

# -----------------------------------------------
# DATA SOURCES - DEV ROUTE TABLES PER AZ
# Reads per-AZ private route tables by name tag
# Names set by modules/vpc/main.tf
# -----------------------------------------------
data "aws_route_table" "dev_workload_private_az_a" {
  provider = aws.dev_workload
  filter {
    name   = "tag:Name"
    values = ["dev-workload-private-rt-1"]
  }
}

data "aws_route_table" "dev_workload_private_az_b" {
  provider = aws.dev_workload
  filter {
    name   = "tag:Name"
    values = ["dev-workload-private-rt-2"]
  }
}

# -----------------------------------------------
# DATA SOURCES - PROD WORKLOAD VPC
# Reads existing prod VPC deployed by prod/vpc
# -----------------------------------------------
data "aws_vpc" "prod_workload" {
  provider   = aws.prod_workload
  cidr_block = var.prod_workload_vpc_cidr
}

# -----------------------------------------------
# DATA SOURCES - PROD ROUTE TABLES PER AZ
# -----------------------------------------------
data "aws_route_table" "prod_workload_private_az_a" {
  provider = aws.prod_workload
  filter {
    name   = "tag:Name"
    values = ["prod-workload-private-rt-1"]
  }
}

data "aws_route_table" "prod_workload_private_az_b" {
  provider = aws.prod_workload
  filter {
    name   = "tag:Name"
    values = ["prod-workload-private-rt-2"]
  }
}

# -----------------------------------------------
# DATA SOURCES - SHARED SECURITY VPC
# Reads existing security VPC from shared/vpc
# -----------------------------------------------
data "aws_vpc" "security" {
  provider   = aws.security
  cidr_block = var.security_vpc_cidr
}

# -----------------------------------------------
# DATA SOURCES - SECURITY ROUTE TABLES PER AZ
# -----------------------------------------------
data "aws_route_table" "security_private_az_a" {
  provider = aws.security
  filter {
    name   = "tag:Name"
    values = ["shared-security-private-rt-1"]
  }
}

data "aws_route_table" "security_private_az_b" {
  provider = aws.security
  filter {
    name   = "tag:Name"
    values = ["shared-security-private-rt-2"]
  }
}

# -----------------------------------------------
# DEV TO SECURITY PEERING
# Connects dev workload VPC to shared security VPC
# Routes added per AZ for intra-AZ traffic flow
# -----------------------------------------------
module "dev_to_security_peering" {
  source = "../../modules/vpc-peering"

  providers = {
    aws.requester = aws.dev_workload
    aws.accepter  = aws.security
  }

  aws_region                    = var.aws_region
  environment                   = "dev"
  peering_name                  = "dev-to-security"
  requester_vpc_id              = data.aws_vpc.dev_workload.id
  requester_vpc_cidr            = var.dev_workload_vpc_cidr
  requester_route_table_az_a_id = data.aws_route_table.dev_workload_private_az_a.id
  requester_route_table_az_b_id = data.aws_route_table.dev_workload_private_az_b.id
  accepter_account_id           = var.security_account_id
  accepter_vpc_id               = data.aws_vpc.security.id
  accepter_vpc_cidr             = var.security_vpc_cidr
  accepter_route_table_az_a_id  = data.aws_route_table.security_private_az_a.id
  accepter_route_table_az_b_id  = data.aws_route_table.security_private_az_b.id
}

# -----------------------------------------------
# PROD TO SECURITY PEERING
# Connects prod workload VPC to shared security VPC
# Completely isolated from dev peering connection
# -----------------------------------------------
module "prod_to_security_peering" {
  source = "../../modules/vpc-peering"

  providers = {
    aws.requester = aws.prod_workload
    aws.accepter  = aws.security
  }

  aws_region                    = var.aws_region
  environment                   = "prod"
  peering_name                  = "prod-to-security"
  requester_vpc_id              = data.aws_vpc.prod_workload.id
  requester_vpc_cidr            = var.prod_workload_vpc_cidr
  requester_route_table_az_a_id = data.aws_route_table.prod_workload_private_az_a.id
  requester_route_table_az_b_id = data.aws_route_table.prod_workload_private_az_b.id
  accepter_account_id           = var.security_account_id
  accepter_vpc_id               = data.aws_vpc.security.id
  accepter_vpc_cidr             = var.security_vpc_cidr
  accepter_route_table_az_a_id  = data.aws_route_table.security_private_az_a.id
  accepter_route_table_az_b_id  = data.aws_route_table.security_private_az_b.id
}
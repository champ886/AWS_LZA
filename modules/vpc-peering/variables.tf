# -----------------------------------------------
# AWS REGION
# Both VPCs must be in the same region
# Cross region peering requires different setup
# -----------------------------------------------
variable "aws_region" {
  description = "AWS region for both VPCs"
  type        = string
}

# -----------------------------------------------
# ENVIRONMENT AND PEERING NAME
# Used for resource naming and tagging
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "peering_name" {
  description = "Descriptive name for this peering"
  type        = string
}

# -----------------------------------------------
# REQUESTER (WORKLOAD) VPC DETAILS
# The account initiating the peering request
# -----------------------------------------------
variable "requester_vpc_id" {
  description = "VPC ID of the requester workload VPC"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "CIDR block of the requester workload VPC"
  type        = string
}

# -----------------------------------------------
# REQUESTER ROUTE TABLES PER AZ
# Separate route tables per AZ ensures traffic
# stays intra-AZ across the peering connection
# -----------------------------------------------
variable "requester_route_table_az_a_id" {
  description = "Private route table ID for AZ-a in requester VPC"
  type        = string
}

variable "requester_route_table_az_b_id" {
  description = "Private route table ID for AZ-b in requester VPC"
  type        = string
}

# -----------------------------------------------
# ACCEPTER (SECURITY) VPC DETAILS
# The account accepting the peering request
# -----------------------------------------------
variable "accepter_account_id" {
  description = "AWS account ID of the accepter security account"
  type        = string
}

variable "accepter_vpc_id" {
  description = "VPC ID of the accepter security VPC"
  type        = string
}

variable "accepter_vpc_cidr" {
  description = "CIDR block of the accepter security VPC"
  type        = string
}

# -----------------------------------------------
# ACCEPTER ROUTE TABLES PER AZ
# Separate route tables per AZ on security side
# -----------------------------------------------
variable "accepter_route_table_az_a_id" {
  description = "Private route table ID for AZ-a in accepter VPC"
  type        = string
}

variable "accepter_route_table_az_b_id" {
  description = "Private route table ID for AZ-b in accepter VPC"
  type        = string
}
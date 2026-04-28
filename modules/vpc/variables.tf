# -----------------------------------------------
# ENVIRONMENT
# Used in resource naming and tagging
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

# -----------------------------------------------
# ACCOUNT NAME
# Used in resource naming e.g. workload or security
# -----------------------------------------------
variable "account_name" {
  description = "Account name workload or security"
  type        = string
}

# -----------------------------------------------
# VPC CIDR
# Overall IP range for the VPC
# Must not overlap with other VPCs if peering later
# -----------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# -----------------------------------------------
# PUBLIC SUBNET CIDRS
# One subnet is created per entry in the list
# -----------------------------------------------
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

# -----------------------------------------------
# PRIVATE SUBNET CIDRS
# One subnet is created per entry in the list
# -----------------------------------------------
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# -----------------------------------------------
# AVAILABILITY ZONES
# Must match the length of subnet CIDR lists
# -----------------------------------------------
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
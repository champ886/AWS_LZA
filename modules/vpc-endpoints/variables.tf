# -----------------------------------------------
# ENVIRONMENT AND NAME
# Used for resource naming and tagging
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Name label e.g. workload or security"
  type        = string
}

# -----------------------------------------------
# REGION
# Used to construct the service endpoint names
# e.g. com.amazonaws.ap-southeast-2.eks
# -----------------------------------------------
variable "region" {
  description = "AWS region"
  type        = string
}

# -----------------------------------------------
# VPC DETAILS
# VPC ID and CIDR for endpoint placement
# and security group ingress rule
# -----------------------------------------------
variable "vpc_id" {
  description = "VPC ID to create endpoints in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group ingress"
  type        = string
}

# -----------------------------------------------
# SUBNET IDS
# Interface endpoints placed in private subnets
# -----------------------------------------------
variable "private_subnet_ids" {
  description = "Private subnet IDs for interface endpoints"
  type        = list(string)
}

# -----------------------------------------------
# ROUTE TABLE IDS
# Gateway endpoints (S3) need route table IDs
# not subnet IDs — different from interface type
# -----------------------------------------------
variable "private_route_table_ids" {
  description = "Private route table IDs for gateway endpoints"
  type        = list(string)
}
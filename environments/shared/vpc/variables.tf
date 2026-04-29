# -----------------------------------------------
# AWS REGION
# -----------------------------------------------
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

# -----------------------------------------------
# ENVIRONMENT
# Fixed as shared for this directory
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "shared"
}

# -----------------------------------------------
# SECURITY ACCOUNT ID
# The single security account shared by all envs
# -----------------------------------------------
variable "security_account_id" {
  description = "Security account ID"
  type        = string
}

# -----------------------------------------------
# SECURITY VPC CIDRS
# Uses 10.1.0.0/16 range
# Must not overlap with dev or prod workload VPCs
# -----------------------------------------------
variable "security_vpc_cidr" {
  description = "CIDR block for shared security VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "security_public_subnet_cidrs" {
  description = "Public subnet CIDRs for security VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "security_private_subnet_cidrs" {
  description = "Private subnet CIDRs for security VPC"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

# -----------------------------------------------
# AVAILABILITY ZONES
# -----------------------------------------------
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}
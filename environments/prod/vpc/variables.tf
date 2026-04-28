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
# Fixed as prod for this directory
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# -----------------------------------------------
# ACCOUNT IDS
# Prod uses a different workload account from dev
# Security account is the same as dev
# -----------------------------------------------
variable "workload_account_id" {
  description = "Prod workload account ID"
  type        = string
}

variable "security_account_id" {
  description = "Security account ID"
  type        = string
}

# -----------------------------------------------
# PROD WORKLOAD VPC CIDRS
# Uses 10.2.x.x range
# Different from dev 10.0.x.x to avoid overlap
# -----------------------------------------------
variable "workload_vpc_cidr" {
  description = "CIDR block for workload VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "workload_public_subnet_cidrs" {
  description = "Public subnet CIDRs for workload VPC"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "workload_private_subnet_cidrs" {
  description = "Private subnet CIDRs for workload VPC"
  type        = list(string)
  default     = ["10.2.3.0/24", "10.2.4.0/24"]
}

# -----------------------------------------------
# PROD SECURITY VPC CIDRS
# Uses 10.3.x.x range
# -----------------------------------------------
variable "security_vpc_cidr" {
  description = "CIDR block for security VPC"
  type        = string
  default     = "10.3.0.0/16"
}

variable "security_public_subnet_cidrs" {
  description = "Public subnet CIDRs for security VPC"
  type        = list(string)
  default     = ["10.3.1.0/24", "10.3.2.0/24"]
}

variable "security_private_subnet_cidrs" {
  description = "Private subnet CIDRs for security VPC"
  type        = list(string)
  default     = ["10.3.3.0/24", "10.3.4.0/24"]
}

# -----------------------------------------------
# AVAILABILITY ZONES
# Two AZs for prod high availability
# -----------------------------------------------
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}
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
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# -----------------------------------------------
# DEV WORKLOAD ACCOUNT ID
# -----------------------------------------------
variable "workload_account_id" {
  description = "Dev workload account ID"
  type        = string
}

# -----------------------------------------------
# DEV WORKLOAD VPC CIDRS
# -----------------------------------------------
variable "workload_vpc_cidr" {
  description = "CIDR block for workload VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "workload_public_subnet_cidrs" {
  description = "Public subnet CIDRs for workload VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "workload_private_subnet_cidrs" {
  description = "Private subnet CIDRs for workload VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# -----------------------------------------------
# AVAILABILITY ZONES
# -----------------------------------------------
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}


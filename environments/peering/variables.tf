# -----------------------------------------------
# AWS REGION
# All VPCs must be in the same region
# -----------------------------------------------
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

# -----------------------------------------------
# ACCOUNT IDS
# All three accounts involved in peering
# -----------------------------------------------
variable "dev_workload_account_id" {
  description = "Dev workload account ID"
  type        = string
}

variable "prod_workload_account_id" {
  description = "Prod workload account ID"
  type        = string
}

variable "security_account_id" {
  description = "Shared security account ID"
  type        = string
}

# -----------------------------------------------
# VPC CIDRS
# Used by data sources to look up existing VPCs
# Must match exactly what was deployed
# -----------------------------------------------
variable "dev_workload_vpc_cidr" {
  description = "CIDR of the dev workload VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "prod_workload_vpc_cidr" {
  description = "CIDR of the prod workload VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "security_vpc_cidr" {
  description = "CIDR of the shared security VPC"
  type        = string
  default     = "10.1.0.0/16"
}
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "workload_account_id" {
  description = "AWS Account ID of the workload account"
  type        = string
}

variable "security_account_id" {
  description = "AWS Account ID of the security account"
  type        = string
}

variable "workload_vpc_cidr" {
  description = "CIDR block for the workload VPC"
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

variable "security_vpc_cidr" {
  description = "CIDR block for the security VPC"
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

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}
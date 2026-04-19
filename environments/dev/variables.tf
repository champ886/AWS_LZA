variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "org_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 90
}

variable "workload_account_name" {
  description = "Name of the workload AWS account"
  type        = string
}

variable "workload_account_email" {
  description = "Email address for the workload AWS account"
  type        = string
}

variable "security_account_name" {
  description = "Name of the security AWS account"
  type        = string
}

variable "security_account_email" {
  description = "Email address for the security AWS account"
  type        = string
}
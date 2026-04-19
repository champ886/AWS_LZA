variable "environment" {
  description = "Environment name"
  type        = string
}

variable "org_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "workload_ou_id" {
  description = "ID of the Workload OU"
  type        = string
}

variable "security_ou_id" {
  description = "ID of the Security OU"
  type        = string
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
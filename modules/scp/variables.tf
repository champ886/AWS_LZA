variable "environment" {
  description = "Environment name"
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

variable "approved_regions" {
  description = "List of approved AWS regions"
  type        = list(string)
  default     = ["ap-southeast-2, ap-southeast-4"]
  }
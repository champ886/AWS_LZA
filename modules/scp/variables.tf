variable "environment" {
  description = "Environment name"
  type        = string
}

variable "workload_ou_id" {
  description = "ID of the Workload OU to attach SCP to"
  type        = string
}

variable "security_ou_id" {
  description = "ID of the Security OU to attach SCP to"
  type        = string
}
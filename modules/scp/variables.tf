# -----------------------------------------------
# ENVIRONMENT
# Used to prefix SCP policy names
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

# -----------------------------------------------
# OU IDS
# SCPs are attached to these OUs so all accounts
# inside them automatically inherit the policies
# -----------------------------------------------
variable "workload_ou_id" {
  description = "ID of the Workload OU"
  type        = string
}

variable "security_ou_id" {
  description = "ID of the Security OU"
  type        = string
}

# -----------------------------------------------
# APPROVED REGIONS
# Any region not in this list will be blocked
# by the region restriction SCP
# -----------------------------------------------
variable "approved_regions" {
  description = "List of approved AWS regions"
  type        = list(string)
  default     = ["ap-southeast-2", "ap-southeast-4"]
}
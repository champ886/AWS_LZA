# -----------------------------------------------
# ENVIRONMENT
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

# -----------------------------------------------
# ANALYZER TYPE
# ACCOUNT — analyses resources in a single account
# ORGANIZATION — analyses resources across all
# accounts in the org, must run in management account
# -----------------------------------------------
variable "analyzer_type" {
  description = "Type of analyzer — ACCOUNT or ORGANIZATION"
  type        = string
  default     = "ORGANIZATION"
}
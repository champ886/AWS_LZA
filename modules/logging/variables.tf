# -----------------------------------------------
# ENVIRONMENT
# Used to prefix logging resource names
# -----------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
}

# -----------------------------------------------
# LOG RETENTION DAYS
# After this period CloudWatch logs are deleted
# Reduce to 30 days in non-prod to save cost
# -----------------------------------------------
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}
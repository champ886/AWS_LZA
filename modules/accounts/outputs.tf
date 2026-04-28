# -----------------------------------------------
# DEV WORKLOAD ACCOUNT ID
# -----------------------------------------------
output "workload_dev_account_id" {
  description = "Account ID of the workload dev account"
  value       = aws_organizations_account.workload_dev.id
}

# -----------------------------------------------
# PROD WORKLOAD ACCOUNT ID
# -----------------------------------------------
output "workload_prod_account_id" {
  description = "Account ID of the workload prod account"
  value       = aws_organizations_account.workload_prod.id
}

# -----------------------------------------------
# SECURITY ACCOUNT ID
# -----------------------------------------------
output "security_account_id" {
  description = "Account ID of the security account"
  value       = aws_organizations_account.security.id
}
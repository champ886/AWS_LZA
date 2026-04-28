# -----------------------------------------------
# DEV WORKLOAD ACCOUNT ID
# Used by dev VPC environment to assume role
# into the dev workload account
# -----------------------------------------------
output "workload_dev_account_id" {
  description = "Account ID of the workload dev account"
  value       = aws_organizations_account.workload_dev.id
}

# -----------------------------------------------
# PROD WORKLOAD ACCOUNT ID
# Used by prod VPC environment to assume role
# into the prod workload account
# -----------------------------------------------
output "workload_prod_account_id" {
  description = "Account ID of the workload prod account"
  value       = aws_organizations_account.workload_prod.id
}

# -----------------------------------------------
# SECURITY ACCOUNT ID
# Used by both dev and prod VPC environments
# -----------------------------------------------
output "security_account_id" {
  description = "Account ID of the security account"
  value       = aws_organizations_account.security.id
}
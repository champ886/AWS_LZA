# -----------------------------------------------
# WORKLOAD OU ID
# Used by accounts module to place accounts in
# the correct OU and by scp module to attach policies
# -----------------------------------------------
output "workload_ou_id" {
  description = "ID of the Workload OU"
  value       = aws_organizations_organizational_unit.workload.id
}

# -----------------------------------------------
# SECURITY OU ID
# Used by accounts module and scp module
# -----------------------------------------------
output "security_ou_id" {
  description = "ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}

# -----------------------------------------------
# ORGANIZATION ID
# Exposed for reference by other modules
# -----------------------------------------------
output "organization_id" {
  description = "ID of the Organization"
  value       = aws_organizations_organization.main.id
}

# -----------------------------------------------
# ROOT ID
# Top level parent of all OUs in the organization
# -----------------------------------------------
output "root_id" {
  description = "ID of the Organization root"
  value       = aws_organizations_organization.main.roots[0].id
}
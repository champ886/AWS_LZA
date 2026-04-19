output "workload_ou_id" {
  description = "ID of the Workload OU"
  value       = aws_organizations_organizational_unit.workload.id
}

output "security_ou_id" {
  description = "ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}
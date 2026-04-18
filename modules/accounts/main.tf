resource "aws_organizations_account" "log_archive" {
  name      = "log-archive"
  email     = var.log_archive_email
  parent_id = var.security_ou_id
}

resource "aws_organizations_account" "workload" {
  name      = "workload"
  email     = var.workload_email
  parent_id = var.workloads_ou_id
}

output "log_archive_account_id" {
  value = aws_organizations_account.log_archive.id
}

output "workload_account_id" {
  value = aws_organizations_account.workload.id
}
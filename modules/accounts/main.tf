resource "aws_organizations_account" "workload_dev" {
  name      = var.workload_account_name
  email     = var.workload_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = var.workload_ou_id

  tags = {
    Environment = var.environment
    OU          = "Workload"
    ManagedBy   = "Terraform"
  }
}

resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = var.security_ou_id

  tags = {
    Environment = var.environment
    OU          = "Security"
    ManagedBy   = "Terraform"
  }
}
# -----------------------------------------------
# WORKLOAD PROVIDER ONLY
# Security provider removed - managed by shared/vpc
# -----------------------------------------------
provider "aws" {
  alias  = "workload"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
}
# -----------------------------------------------
# SECURITY PROVIDER
# Assumes role into the shared security account
# This VPC is shared by both dev and prod
# -----------------------------------------------
provider "aws" {
  alias  = "security"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}
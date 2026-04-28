# -----------------------------------------------
# WORKLOAD PROVIDER
# Assumes role into the prod workload account
# Identical pattern to dev but points to prod
# -----------------------------------------------
provider "aws" {
  alias  = "workload"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
}

# -----------------------------------------------
# SECURITY PROVIDER
# Same security account is shared between
# dev and prod environments
# -----------------------------------------------
provider "aws" {
  alias  = "security"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}
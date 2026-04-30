# -----------------------------------------------
# DEFAULT PROVIDER
# Management account context
# -----------------------------------------------
provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------
# DEV WORKLOAD PROVIDER
# Assumes role into dev workload account
# Used as requester for dev-to-security peering
# -----------------------------------------------
provider "aws" {
  alias  = "dev_workload"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.dev_workload_account_id}:role/OrganizationAccountAccessRole"
  }
}

# -----------------------------------------------
# PROD WORKLOAD PROVIDER
# Assumes role into prod workload account
# Used as requester for prod-to-security peering
# -----------------------------------------------
provider "aws" {
  alias  = "prod_workload"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.prod_workload_account_id}:role/OrganizationAccountAccessRole"
  }
}

# -----------------------------------------------
# SECURITY PROVIDER
# Assumes role into security account
# Used as accepter for both peering connections
# -----------------------------------------------
provider "aws" {
  alias  = "security"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}
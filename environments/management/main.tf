# -----------------------------------------------
# ORGANIZATION MODULE
# Deploys AWS Organization, OUs and org settings
# Must run first as all other modules depend on it
# -----------------------------------------------
module "organization" {
  source = "../../modules/organization"
}

# -----------------------------------------------
# ACCOUNTS MODULE
# Deploys all AWS accounts into their OUs
# depends_on ensures org and OUs exist first
# -----------------------------------------------
module "accounts" {
  source                      = "../../modules/accounts"
  environment                 = var.environment
  org_id                      = var.org_id
  workload_ou_id              = module.organization.workload_ou_id
  security_ou_id              = module.organization.security_ou_id
  workload_dev_account_name   = var.workload_dev_account_name
  workload_dev_account_email  = var.workload_dev_account_email
  workload_prod_account_name  = var.workload_prod_account_name
  workload_prod_account_email = var.workload_prod_account_email
  security_account_name       = var.security_account_name
  security_account_email      = var.security_account_email

  depends_on = [module.organization]
}

# -----------------------------------------------
# CONFIG MODULE
# Deploys AWS Config recorder and IAM role
# depends_on ensures org exists for integration
# -----------------------------------------------
module "config" {
  source      = "../../modules/config"
  environment = var.environment

  depends_on = [module.organization]
}

# -----------------------------------------------
# LOGGING MODULE
# Deploys CloudWatch log group and S3 archive
# No org dependency so runs in parallel
# -----------------------------------------------
module "logging" {
  source             = "../../modules/logging"
  environment        = var.environment
  log_retention_days = var.log_retention_days
}

# -----------------------------------------------
# SCP MODULE
# Deploys all SCPs and attaches to OUs
# depends_on ensures OUs exist before attachment
# -----------------------------------------------
module "scp" {
  source           = "../../modules/scp"
  environment      = var.environment
  workload_ou_id   = module.organization.workload_ou_id
  security_ou_id   = module.organization.security_ou_id
  approved_regions = var.approved_regions

  depends_on = [module.organization]
}
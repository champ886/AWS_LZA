module "organization" {
  source = "../../modules/organization"
}

module "accounts" {
  source                 = "../../modules/accounts"
  environment            = var.environment
  org_id                 = var.org_id
  workload_ou_id         = module.organization.workload_ou_id
  security_ou_id         = module.organization.security_ou_id
  workload_account_name  = var.workload_account_name
  workload_account_email = var.workload_account_email
  security_account_name  = var.security_account_name
  security_account_email = var.security_account_email

  depends_on = [module.organization]
}

module "config" {
  source      = "../../modules/config"
  environment = var.environment

  depends_on = [module.organization]
}

module "logging" {
  source             = "../../modules/logging"
  environment        = var.environment
  log_retention_days = var.log_retention_days
}

module "scp" {
  source      = "../../modules/scp"
  environment = var.environment

  depends_on = [module.organization]
}
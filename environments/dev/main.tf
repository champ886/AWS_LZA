module "organization" {
  source = "../../modules/organization"
}

module "accounts" {
  source = "../../modules/accounts"

  log_archive_email = var.log_archive_email
  workload_email    = var.workload_email

  security_ou_id  = module.organization.security_ou_id
  workloads_ou_id = module.organization.workloads_ou_id
}

module "scp" {
  source = "../../modules/scp"

  target_id = module.organization.root_id
}

module "logging" {
  source = "../../modules/logging"

  bucket_name = var.log_bucket_name
}

module "config" {
  source = "../../modules/config"

  bucket_name     = var.log_bucket_name
  config_role_arn = var.config_role_arn
}
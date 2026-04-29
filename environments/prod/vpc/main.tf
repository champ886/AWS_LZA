# -----------------------------------------------
# PROD WORKLOAD VPC ONLY
# Security VPC is managed by environments/shared/vpc
# -----------------------------------------------
module "vpc_workload" {
  source = "../../../modules/vpc"

  providers = {
    aws = aws.workload
  }

  environment          = var.environment
  account_name         = "workload"
  vpc_cidr             = var.workload_vpc_cidr
  public_subnet_cidrs  = var.workload_public_subnet_cidrs
  private_subnet_cidrs = var.workload_private_subnet_cidrs
  availability_zones   = var.availability_zones
}

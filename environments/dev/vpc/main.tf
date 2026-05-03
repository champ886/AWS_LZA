# -----------------------------------------------
# DEV WORKLOAD VPC ONLY
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

# -----------------------------------------------
# DEV WORKLOAD VPC ENDPOINTS
# Required for EKS nodes in private subnets
# to reach AWS APIs without a NAT gateway
# Deployed separately to keep vpc module clean
# -----------------------------------------------
module "vpc_endpoints_workload" {
  source = "../../../modules/vpc-endpoints"

  providers = {
    aws = aws.workload
  }

  environment             = var.environment
  name                    = "workload"
  region                  = var.aws_region
  vpc_id                  = module.vpc_workload.vpc_id
  vpc_cidr                = var.workload_vpc_cidr
  private_subnet_ids      = module.vpc_workload.private_subnet_ids
  private_route_table_ids = module.vpc_workload.private_route_table_ids

  depends_on = [module.vpc_workload]
}
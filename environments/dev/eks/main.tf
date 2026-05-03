# -----------------------------------------------
# DATA SOURCES
# Reads existing dev VPC 10.0.0.0/16 created
# by environments/dev/vpc — no hardcoded IDs
# -----------------------------------------------
data "aws_vpc" "dev_workload" {
  provider   = aws.workload
  cidr_block = "10.0.0.0/16"
}

data "aws_subnets" "private" {
  provider = aws.workload
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev_workload.id]
  }
  tags = {
    Type = "Private"
  }
}

data "aws_subnets" "public" {
  provider = aws.workload
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev_workload.id]
  }
  tags = {
    Type = "Public"
  }
}

# -----------------------------------------------
# CURRENT ACCOUNT DATA SOURCE
# Returns 435321828725 — passed to Kubecost
# for accurate AWS pricing data
# -----------------------------------------------
data "aws_caller_identity" "current" {
  provider = aws.workload
}

# -----------------------------------------------
# EKS CLUSTER MODULE
# Deploys lean-dev cluster into dev workload
# account 435321828725 in ap-southeast-2
# Using existing dev VPC 10.0.0.0/16
# 2x t3.medium spot nodes — scales to 5
# -----------------------------------------------
module "eks" {
  source = "../../../modules/eks"

  providers = {
    aws = aws.workload
  }

  cluster_name                         = "lean-dev"
  environment                          = "dev"
  kubernetes_version                   = "1.32"  
  vpc_id                               = data.aws_vpc.dev_workload.id
  private_subnet_ids                   = data.aws_subnets.private.ids
  public_subnet_ids                    = data.aws_subnets.public.ids
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  node_instance_types                  = ["t3.medium"]
  node_desired_size                    = 2
  node_min_size                        = 1
  node_max_size                        = 5
}

# -----------------------------------------------
# EKS ADDONS MODULE
# Installs into lean-dev cluster:
# — Cluster autoscaler (scales nodes automatically)
# — Kubecost free tier (cost monitoring dashboard)
# — AWS load balancer controller (ALB ingress)
# Must run after eks module completes
# -----------------------------------------------
module "eks_addons" {
  source = "../../../modules/eks-addons"

  cluster_name              = module.eks.cluster_name
  environment               = "dev"
  aws_region                = "ap-southeast-2"
  aws_account_id            = "435321828725"
  vpc_id                    = data.aws_vpc.dev_workload.id
  cluster_endpoint          = module.eks.cluster_endpoint
  cluster_ca_certificate    = module.eks.cluster_ca_certificate
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn

  depends_on = [module.eks]
}
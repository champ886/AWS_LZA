# -----------------------------------------------
# DATA SOURCES
# Reads existing dev VPC created by dev/vpc
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

data "aws_caller_identity" "current" {
  provider = aws.workload
}

# -----------------------------------------------
# EKS CLUSTER MODULE
# Step 1 — deploy this first on its own
# terraform apply -target=module.eks
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
# Step 2 — core addons + autoscaler + kubecost
# ALB controller removed — in its own module below
# terraform apply -target=module.eks_addons
# -----------------------------------------------
module "eks_addons" {
  source = "../../../modules/eks-addons"

  providers = {
    aws.workload = aws.workload
    helm         = helm
    kubernetes   = kubernetes
  }

  cluster_name              = module.eks.cluster_name
  environment               = "dev"
  aws_region                = "ap-southeast-2"
  aws_account_id            = "435321828725"
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn

  depends_on = [module.eks]
}

# -----------------------------------------------
# ALB CONTROLLER MODULE
# Step 3 — deploy last after core addons running
# Isolated so webhook issues never block kubecost
# or autoscaler installations
# terraform apply -target=module.alb_controller
# -----------------------------------------------
module "alb_controller" {
  source = "../../../modules/alb-controller"

  providers = {
    aws.workload = aws.workload
    helm         = helm
  }

  cluster_name              = module.eks.cluster_name
  environment               = "dev"
  aws_region                = "ap-southeast-2"
  vpc_id                    = data.aws_vpc.dev_workload.id
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn

  depends_on = [module.eks_addons]
}
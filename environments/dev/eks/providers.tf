# -----------------------------------------------
# AWS PROVIDER
# -----------------------------------------------
provider "aws" {
  alias  = "workload"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::435321828725:role/OrganizationAccountAccessRole"
  }
}

# -----------------------------------------------
# HELM PROVIDER
# kubernetes block is correct syntax for v2
# -----------------------------------------------
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        "lean-dev",
        "--region",
        "ap-southeast-2",
        "--role-arn",
        "arn:aws:iam::435321828725:role/OrganizationAccountAccessRole",
      ]
    }
  }
}

# -----------------------------------------------
# KUBERNETES PROVIDER
# -----------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      "lean-dev",
      "--region",
      "ap-southeast-2",
      "--role-arn",
      "arn:aws:iam::435321828725:role/OrganizationAccountAccessRole",
    ]
  }
}
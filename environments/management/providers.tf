# -----------------------------------------------
# DEFAULT AWS PROVIDER
# All resources in this environment deploy into
# the management account using these credentials
# -----------------------------------------------
provider "aws" {
  region = var.aws_region
}
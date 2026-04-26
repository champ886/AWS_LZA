terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "workload"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "security"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}

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

module "vpc_security" {
  source = "../../../modules/vpc"

  providers = {
    aws = aws.security
  }

  environment          = var.environment
  account_name         = "security"
  vpc_cidr             = var.security_vpc_cidr
  public_subnet_cidrs  = var.security_public_subnet_cidrs
  private_subnet_cidrs = var.security_private_subnet_cidrs
  availability_zones   = var.availability_zones
}
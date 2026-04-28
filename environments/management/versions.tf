# -----------------------------------------------
# TERRAFORM AND PROVIDER VERSION CONSTRAINTS
# Ensures all team members use compatible versions
# ~> 5.0 allows 5.x updates but blocks 6.0
# -----------------------------------------------
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
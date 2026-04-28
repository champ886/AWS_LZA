# -----------------------------------------------
# REMOTE STATE BACKEND
# Prod VPC state completely isolated from
# dev and management state files
# -----------------------------------------------
terraform {
  backend "s3" {
    bucket         = "tf-state-landing-zone-champ-001"
    key            = "aws-lza/prod/vpc/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}


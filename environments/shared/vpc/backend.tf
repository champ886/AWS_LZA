# -----------------------------------------------
# REMOTE STATE BACKEND
# Shared VPC state stored separately so neither
# dev nor prod destroy can affect it
# -----------------------------------------------
terraform {
  backend "s3" {
    bucket         = "tf-state-landing-zone-champ-001"
    key            = "aws-lza/shared/vpc/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
# -----------------------------------------------
# REMOTE STATE BACKEND
# State stored separately from dev and prod
# DynamoDB prevents concurrent state modifications
# -----------------------------------------------
terraform {
  backend "s3" {
    bucket         = "tf-state-landing-zone-champ-001"
    key            = "aws-lza/management/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
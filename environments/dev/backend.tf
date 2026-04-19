terraform {
  backend "s3" {
    bucket         = "tf-state-landing-zone-champ-001"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-locks"
  }
}
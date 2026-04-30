# -----------------------------------------------
# PROVIDER REQUIREMENTS
# -----------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# -----------------------------------------------
# IAM ACCESS ANALYZER
# Free service — no trial period
# Analyses resource policies to identify any
# that grant access to external principals
# Covers S3, IAM roles, KMS keys, Lambda, SQS
# -----------------------------------------------
resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "${var.environment}-access-analyzer"
  type          = var.analyzer_type

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
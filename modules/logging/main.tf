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
# CLOUDWATCH LOG GROUP
# Central log group for LZA logs
# Retention controls how long logs are kept
# before automatic deletion to manage cost
# -----------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/${var.environment}/lza-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# S3 LOG ARCHIVE BUCKET
# Long term storage for logs
# Account ID appended to ensure globally unique name
# -----------------------------------------------
resource "aws_s3_bucket" "log_archive" {
  bucket = "${var.environment}-lza-log-archive-${data.aws_caller_identity.current.account_id}"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# S3 BUCKET VERSIONING
# Keeps multiple copies of each log file
# Protects against accidental deletion or overwrite
# -----------------------------------------------
resource "aws_s3_bucket_versioning" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------
# CURRENT ACCOUNT DATA SOURCE
# Retrieves the current AWS account ID
# Used to make the S3 bucket name globally unique
# -----------------------------------------------
data "aws_caller_identity" "current" {}
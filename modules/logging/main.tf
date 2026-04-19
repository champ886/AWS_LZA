resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/${var.environment}/lza-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "log_archive" {
  bucket = "${var.environment}-lza-log-archive-${data.aws_caller_identity.current.account_id}"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}
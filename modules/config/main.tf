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
# AWS CONFIG RECORDER
# Records configuration changes for all supported
# resource types in the account
# -----------------------------------------------
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.environment}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    # Record every supported AWS resource type automatically
    all_supported = true
  }
}

# -----------------------------------------------
# CONFIG IAM ROLE
# Config needs this role to describe and record
# your AWS resources across the account
# -----------------------------------------------
resource "aws_iam_role" "config_role" {
  name = "${var.environment}-config-role"

  # Trust policy allowing the Config service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
}

# -----------------------------------------------
# CONFIG POLICY ATTACHMENT
# Attaches the AWS managed policy that grants
# Config the permissions it needs to function
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
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
# AWS ORGANIZATION
# Creates the root organization with all features
# enabled including SCP support
# -----------------------------------------------
resource "aws_organizations_organization" "main" {

  # Enable trusted AWS services to integrate with the organization
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com", # allows org-wide CloudTrail
    "config.amazonaws.com"      # allows org-wide AWS Config
  ]

  # ALL enables SCPs and all advanced org features
  feature_set = "ALL"

  # Explicitly enable SCP policy type so we can attach SCPs to OUs
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

# -----------------------------------------------
# WORKLOAD OU
# Contains dev and prod workload accounts
# -----------------------------------------------
resource "aws_organizations_organizational_unit" "workload" {
  name      = "Workload"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# -----------------------------------------------
# SECURITY OU
# Contains the centralised security account
# -----------------------------------------------
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id
}
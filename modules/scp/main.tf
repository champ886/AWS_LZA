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
# SCP 1 - ROOT AND ORG PROTECTION
# Combines three related rules into one policy
# AWS allows max 5 SCPs per OU so we consolidate
# to leave slots available for future policies
# -----------------------------------------------
resource "aws_organizations_policy" "deny_root_and_org" {
  name        = "${var.environment}-deny-root-and-org"
  description = "Deny root access and leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Block root user from all actions in any account
        # Root bypasses IAM so SCP is the only way to restrict it
        Sid       = "DenyRootAccess"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = ["arn:aws:iam::*:root"]
          }
        }
      },
      {
        # Prevent accounts escaping the org and bypassing SCPs
        Sid      = "DenyLeaveOrg"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
        # Prevent the guardrails themselves from being removed
        Sid    = "DenySCPChanges"
        Effect = "Deny"
        Action = [
          "organizations:DeletePolicy",
          "organizations:DetachPolicy",
          "organizations:DisablePolicyType",
          "organizations:UpdatePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------
# SCP 2 - AUDIT AND COMPLIANCE PROTECTION
# Prevents CloudTrail and Config from being
# disabled which would remove audit visibility
# -----------------------------------------------
resource "aws_organizations_policy" "deny_audit_disable" {
  name        = "${var.environment}-deny-audit-disable"
  description = "Prevent CloudTrail and Config from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudTrail is the audit log of all AWS API activity
        Sid    = "DenyCloudTrailDisable"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      },
      {
        # Config tracks resource configuration changes for compliance
        Sid    = "DenyConfigDisable"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------
# SCP 3 - REGION AND SECURITY SERVICE PROTECTION
# Restricts which regions can be used and prevents
# core security services from being disabled
# -----------------------------------------------
resource "aws_organizations_policy" "deny_regions_and_security" {
  name        = "${var.environment}-deny-regions-and-security"
  description = "Deny non approved regions and disabling security services"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Block all services in non-approved regions
        # NotAction exempts global services like IAM and Route53
        # which have no region and must always be accessible
        Sid    = "DenyNonApprovedRegions"
        Effect = "Deny"
        NotAction = [
          "iam:*",
          "sts:*",
          "s3:*",
          "route53:*",
          "cloudfront:*",
          "support:*",
          "organizations:*",
          "ec2:*",                      # ← temporarily allow all EC2 to test
          "billing:*",                  
          "cost-optimization-hub:*",    
          "account:*"                   
              ]
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.approved_regions
          }
        }
      },
      {
        # GuardDuty and Security Hub are primary threat detection services
        Sid    = "DenySecurityDisable"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:StopMonitoringMembers",
          "securityhub:DeleteHub",
          "securityhub:DisableSecurityHub"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------
# ATTACHMENTS - WORKLOAD OU
# All accounts inside Workload OU inherit these
# -----------------------------------------------
resource "aws_organizations_policy_attachment" "full_access_workload" {
  policy_id = "p-FullAWSAccess"
  target_id = var.workload_ou_id
}
resource "aws_organizations_policy_attachment" "deny_root_and_org_workload" {
  policy_id = aws_organizations_policy.deny_root_and_org.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_audit_disable_workload" {
  policy_id = aws_organizations_policy.deny_audit_disable.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_regions_and_security_workload" {
  policy_id = aws_organizations_policy.deny_regions_and_security.id
  target_id = var.workload_ou_id
}

# -----------------------------------------------
# ATTACHMENTS - SECURITY OU
# All accounts inside Security OU inherit these
# -----------------------------------------------
resource "aws_organizations_policy_attachment" "full_access_security" {
  policy_id = "p-FullAWSAccess"
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_root_and_org_security" {
  policy_id = aws_organizations_policy.deny_root_and_org.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_audit_disable_security" {
  policy_id = aws_organizations_policy.deny_audit_disable.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_regions_and_security_security" {
  policy_id = aws_organizations_policy.deny_regions_and_security.id
  target_id = var.security_ou_id
}
# -----------------------------------------------
# 1. DENY ROOT AND ORG CONTROLS (combines 3 SCPs)
# -----------------------------------------------
resource "aws_organizations_policy" "deny_root_and_org" {
  name        = "${var.environment}-deny-root-and-org"
  description = "Deny root access and leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootAccess"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = { "aws:PrincipalArn" = ["arn:aws:iam::*:root"] }
        }
      },
      {
        Sid      = "DenyLeaveOrg"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
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
# 2. DENY AUDIT AND COMPLIANCE DISABLE (combines 2 SCPs)
# -----------------------------------------------
resource "aws_organizations_policy" "deny_audit_disable" {
  name        = "${var.environment}-deny-audit-disable"
  description = "Prevent CloudTrail and Config from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
# 3. DENY REGIONS AND SECURITY DISABLE (combines 2 SCPs)
# -----------------------------------------------
resource "aws_organizations_policy" "deny_regions_and_security" {
  name        = "${var.environment}-deny-regions-and-security"
  description = "Deny non approved regions and disabling security services"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyNonApprovedRegions"
        Effect = "Deny"
        NotAction = [
          "iam:*",
          "sts:*",
          "s3:*",
          "route53:*",
          "cloudfront:*",
          "support:*",
          "organizations:*"
        ]
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.approved_regions
          }
        }
      },
      {
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
# -----------------------------------------------
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
# -----------------------------------------------
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
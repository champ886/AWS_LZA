# -----------------------------------------------
# 1. DENY ROOT ACCESS
# -----------------------------------------------
resource "aws_organizations_policy" "deny_root_access" {
  name        = "${var.environment}-deny-root-access"
  description = "Deny root account usage"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyRootAccess"
      Effect    = "Deny"
      Action    = "*"
      Resource  = "*"
      Condition = {
        StringLike = { "aws:PrincipalArn" = ["arn:aws:iam::*:root"] }
      }
    }]
  })
}

# -----------------------------------------------
# 2. DENY LEAVING THE ORGANIZATION
# -----------------------------------------------
resource "aws_organizations_policy" "deny_leave_org" {
  name        = "${var.environment}-deny-leave-org"
  description = "Prevent accounts from leaving the Organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyLeaveOrg"
      Effect   = "Deny"
      Action   = "organizations:LeaveOrganization"
      Resource = "*"
    }]
  })
}

# -----------------------------------------------
# 3. DENY DISABLING CLOUDTRAIL
# -----------------------------------------------
resource "aws_organizations_policy" "deny_cloudtrail_disable" {
  name        = "${var.environment}-deny-cloudtrail-disable"
  description = "Prevent CloudTrail from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyCloudTrailDisable"
      Effect = "Deny"
      Action = [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ]
      Resource = "*"
    }]
  })
}

# -----------------------------------------------
# 4. DENY DISABLING AWS CONFIG
# -----------------------------------------------
resource "aws_organizations_policy" "deny_config_disable" {
  name        = "${var.environment}-deny-config-disable"
  description = "Prevent AWS Config from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyConfigDisable"
      Effect = "Deny"
      Action = [
        "config:DeleteConfigRule",
        "config:DeleteConfigurationRecorder",
        "config:DeleteDeliveryChannel",
        "config:StopConfigurationRecorder"
      ]
      Resource = "*"
    }]
  })
}

# -----------------------------------------------
# 5. DENY SPECIFIC REGIONS
# -----------------------------------------------
resource "aws_organizations_policy" "deny_non_approved_regions" {
  name        = "${var.environment}-deny-non-approved-regions"
  description = "Deny access to non approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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
      Resource = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = var.approved_regions
        }
      }
    }]
  })
}

# -----------------------------------------------
# 6. DENY REMOVING GUARDRAILS (protect SCPs themselves)
# -----------------------------------------------
resource "aws_organizations_policy" "deny_scp_changes" {
  name        = "${var.environment}-deny-scp-changes"
  description = "Prevent SCPs from being modified or deleted"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenySCPChanges"
      Effect = "Deny"
      Action = [
        "organizations:DeletePolicy",
        "organizations:DetachPolicy",
        "organizations:DisablePolicyType",
        "organizations:UpdatePolicy"
      ]
      Resource = "*"
    }]
  })
}

# -----------------------------------------------
# 7. DENY DISABLING SECURITY HUB / GUARDDUTY
# -----------------------------------------------
resource "aws_organizations_policy" "deny_security_disable" {
  name        = "${var.environment}-deny-security-disable"
  description = "Prevent GuardDuty and Security Hub from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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
    }]
  })
}

# -----------------------------------------------
# ATTACHMENTS - WORKLOAD OU
# -----------------------------------------------
resource "aws_organizations_policy_attachment" "deny_root_workload" {
  policy_id = aws_organizations_policy.deny_root_access.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_leave_org_workload" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_workload" {
  policy_id = aws_organizations_policy.deny_cloudtrail_disable.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_config_workload" {
  policy_id = aws_organizations_policy.deny_config_disable.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_regions_workload" {
  policy_id = aws_organizations_policy.deny_non_approved_regions.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_scp_changes_workload" {
  policy_id = aws_organizations_policy.deny_scp_changes.id
  target_id = var.workload_ou_id
}

resource "aws_organizations_policy_attachment" "deny_security_disable_workload" {
  policy_id = aws_organizations_policy.deny_security_disable.id
  target_id = var.workload_ou_id
}

# -----------------------------------------------
# ATTACHMENTS - SECURITY OU
# -----------------------------------------------
resource "aws_organizations_policy_attachment" "deny_root_security" {
  policy_id = aws_organizations_policy.deny_root_access.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_leave_org_security" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_security" {
  policy_id = aws_organizations_policy.deny_cloudtrail_disable.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_config_security" {
  policy_id = aws_organizations_policy.deny_config_disable.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_regions_security" {
  policy_id = aws_organizations_policy.deny_non_approved_regions.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_scp_changes_security" {
  policy_id = aws_organizations_policy.deny_scp_changes.id
  target_id = var.security_ou_id
}

resource "aws_organizations_policy_attachment" "deny_security_disable_security" {
  policy_id = aws_organizations_policy.deny_security_disable.id
  target_id = var.security_ou_id
}
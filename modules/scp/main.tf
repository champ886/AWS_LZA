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
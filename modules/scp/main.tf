resource "aws_organizations_policy" "deny_root" {
  name = "deny-root-user"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Deny"
      Action = "*"
      Resource = "*"
      Condition = {
        StringLike = {
          "aws:PrincipalArn" = ["arn:aws:iam::*:root"]
        }
      }
    }]
  })

  type = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "attach" {
  policy_id = aws_organizations_policy.deny_root.id
  target_id = var.target_id
}
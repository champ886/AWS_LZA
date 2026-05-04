output "alb_controller_role_arn" {
  description = "IAM role ARN for the ALB controller"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_policy_arn" {
  description = "IAM policy ARN for the ALB controller"
  value       = aws_iam_policy.alb_controller.arn
}

output "helm_release_status" {
  description = "Status of the ALB controller Helm release"
  value       = helm_release.alb_controller.status
}
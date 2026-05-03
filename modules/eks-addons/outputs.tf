output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for cluster autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for ALB controller"
  value       = aws_iam_role.alb_controller.arn
}

output "kubecost_namespace" {
  description = "Namespace where Kubecost is deployed"
  value       = kubernetes_namespace.kubecost.metadata[0].name
}
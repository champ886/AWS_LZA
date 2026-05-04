output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for the cluster autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "kubecost_namespace" {
  description = "Namespace where Kubecost is deployed"
  value       = kubernetes_namespace.kubecost.metadata[0].name
}
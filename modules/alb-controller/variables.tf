variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster runs"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}
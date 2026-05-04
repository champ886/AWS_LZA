# -----------------------------------------------
# PROVIDER REQUIREMENTS
# -----------------------------------------------
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.workload]
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# -----------------------------------------------
# EKS CORE ADDONS — FREE — MANAGED BY AWS
# Must use aws.workload provider — cluster lives
# in dev account 435321828725 not management
# vpc-cni    — pod networking
# coredns    — internal DNS resolution
# kube-proxy — maintains network rules on nodes
# -----------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  provider                    = aws.workload
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_addon" "coredns" {
  provider                    = aws.workload
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  provider                    = aws.workload
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# CLUSTER AUTOSCALER IAM ROLE
# IRSA — scoped only to autoscaler service account
# -----------------------------------------------
resource "aws_iam_role" "cluster_autoscaler" {
  provider = aws.workload
  name     = "${var.cluster_name}-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.cluster_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  provider = aws.workload
  name     = "${var.cluster_name}-autoscaler-policy"
  role     = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------
# CLUSTER AUTOSCALER HELM CHART
# Aggressively scales down idle nodes to save cost
# 50% utilisation threshold — scale down below
# 5 minutes idle time before node removal
# -----------------------------------------------
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.29.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.scale-down-utilization-threshold"
    value = "0.5"
  }

  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "5m"
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "5m"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "300Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "300Mi"
  }

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    aws_iam_role_policy.cluster_autoscaler
  ]
}

# -----------------------------------------------
# KUBECOST NAMESPACE
# -----------------------------------------------
resource "kubernetes_namespace" "kubecost" {
  metadata {
    name = "kubecost"
    labels = {
      name        = "kubecost"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy
  ]
}

# -----------------------------------------------
# KUBECOST HELM CHART — FREE OPEN SOURCE TIER
# Empty kubecostToken = free tier, no expiry
# Access: kubectl port-forward -n kubecost
#         svc/kubecost-cost-analyzer 9090:9090
# -----------------------------------------------
resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer"
  chart      = "cost-analyzer"
  namespace  = kubernetes_namespace.kubecost.metadata[0].name
  version    = "1.108.0"

  set {
    name  = "kubecostToken"
    value = ""
  }

  set {
    name  = "prometheus.server.persistentVolume.size"
    value = "8Gi"
  }

  set {
    name  = "prometheus.server.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "prometheus.server.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "prometheus.server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "prometheus.server.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "cost-analyzer.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "cost-analyzer.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "cost-analyzer.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "cost-analyzer.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "kubecostProductConfigs.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "kubecostProductConfigs.projectID"
    value = var.aws_account_id
  }

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    kubernetes_namespace.kubecost
  ]
}
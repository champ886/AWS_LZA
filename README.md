# EKS + VPC Endpoints + Kubecost — Setup Guide

A complete guide to deploying a lean, cost-optimised EKS cluster with private networking via VPC endpoints and real-time cost monitoring via Kubecost free tier.

---

## Architecture overview

```
Dev workload account (435321828725)
  └── Dev VPC (10.0.0.0/16)
        ├── Public subnets      — 10.0.1.0/24, 10.0.2.0/24  (AZ-a + AZ-b)
        ├── Private subnets     — 10.0.3.0/24, 10.0.4.0/24  (AZ-a + AZ-b)
        ├── VPC endpoints
        │     ├── EKS           — Interface ($7/month)
        │     ├── ECR API       — Interface ($7/month)
        │     ├── ECR DKR       — Interface ($7/month)
        │     ├── STS           — Interface ($7/month)
        │     ├── EC2           — Interface ($7/month)
        │     ├── Autoscaling   — Interface ($7/month)
        │     └── S3            — Gateway  (FREE)
        └── EKS cluster (lean-dev)
              ├── Control plane — Managed by AWS
              ├── Node group    — 2x t3.medium SPOT (scales 1→5)
              ├── Core addons   — vpc-cni, coredns, kube-proxy
              ├── Cluster autoscaler
              ├── AWS Load Balancer Controller
              └── Kubecost      — Free open source tier
```

---

## Why VPC endpoints instead of a NAT gateway

Worker nodes run in private subnets and need to reach AWS APIs to join the cluster and pull images. There are two ways to give them outbound access:

| Approach | Monthly cost | Security | Traffic path |
|---|---|---|---|
| NAT Gateway | ~$32 | Medium — traffic hits internet | Private subnet → NAT → Internet → AWS |
| VPC Endpoints | ~$42 | High — traffic never leaves AWS | Private subnet → Endpoint → AWS API |
| Public subnets | Free | Low — nodes exposed to internet | Not recommended |

VPC endpoints keep all traffic inside the AWS private network. The kubelet on each worker node calls four groups of AWS APIs:

```
1. Node registration    → EKS endpoint   → EKS control plane API
2. Heartbeat            → EKS endpoint   → EKS control plane API
3. Pull container image → ECR endpoints  → ECR registry + S3 (free)
4. IAM token (IRSA)     → STS endpoint   → STS service
```

Without these endpoints nodes in private subnets have no outbound path and never join the cluster.

---

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI v2.7+ (required for EKS token v1beta1 support)
- kubectl installed
- Existing dev VPC deployed via `environments/dev/vpc`
- Dev workload account `435321828725` accessible via `OrganizationAccountAccessRole`

### Verify AWS CLI version
```bash
aws --version
# must show: aws-cli/2.x.x

# If still on v1 upgrade with:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
```

### Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

---

## Directory structure

```
environments/
  dev/
    vpc/              ← VPC + VPC endpoints (deploy first)
    eks/              ← EKS cluster + addons (deploy second)

modules/
  vpc/                ← VPC, subnets, route tables, IGW
  vpc-endpoints/      ← VPC interface and gateway endpoints
  eks/                ← EKS cluster, node group, OIDC provider
  eks-addons/         ← Core addons, autoscaler, ALB controller, Kubecost
```

---

## Step 1 — Deploy VPC endpoints

The VPC endpoints module is called from inside `environments/dev/vpc` and deploys alongside the VPC. If the VPC already exists, just apply the endpoints module:

```bash
cd ~/terraform-and-eks/AWS_LZA/environments/dev/vpc

# Apply only the endpoints module if VPC already exists
terraform apply \
  -target=module.vpc_endpoints_workload \
  -var-file="terraform.tfvars"
```

### What gets created

| Resource | Type | Purpose |
|---|---|---|
| `aws_vpc_endpoint.eks` | Interface | Kubelet → control plane |
| `aws_vpc_endpoint.ecr_api` | Interface | ECR authentication |
| `aws_vpc_endpoint.ecr_dkr` | Interface | Container image pull |
| `aws_vpc_endpoint.sts` | Interface | IRSA token generation |
| `aws_vpc_endpoint.ec2` | Interface | Node registration |
| `aws_vpc_endpoint.autoscaling` | Interface | Cluster autoscaler scaling |
| `aws_vpc_endpoint.s3` | Gateway | ECR image layer pull (free) |
| `aws_security_group.vpc_endpoints` | Security group | Allow 443 from VPC CIDR only |

### Verify endpoints are active

```bash
# Assume role into dev account first
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

aws ec2 describe-vpc-endpoints \
  --region ap-southeast-2 \
  --filters Name=vpc-id,Values=$(aws ec2 describe-vpcs \
    --filters Name=cidr,Values=10.0.0.0/16 \
    --query 'Vpcs[0].VpcId' \
    --output text) \
  --query 'VpcEndpoints[*].[ServiceName,State]' \
  --output table

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

All endpoints should show `available`.

---

## Step 2 — Deploy EKS cluster

```bash
cd ~/terraform-and-eks/AWS_LZA/environments/dev/eks

terraform init

# Apply EKS cluster and node group first
# Addons need the cluster to be ACTIVE before installing
terraform apply \
  -target=module.eks \
  -var-file="terraform.tfvars"
```

### Verify cluster is ACTIVE before continuing

```bash
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

aws eks describe-cluster \
  --name lean-dev \
  --region ap-southeast-2 \
  --query 'cluster.status' \
  --output text
# must return: ACTIVE

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

---

## Step 3 — Configure kubectl

```bash
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

aws eks update-kubeconfig \
  --name lean-dev \
  --region ap-southeast-2

# Verify nodes are Ready
kubectl get nodes
# should show 2 nodes with STATUS = Ready

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

---

## Step 4 — Deploy EKS addons

Deploy in strict order to avoid dependency issues:

```bash
cd ~/terraform-and-eks/AWS_LZA/environments/dev/eks

# Core addons first — coredns must be running before Helm charts install
terraform apply \
  -target=module.eks_addons.aws_eks_addon.vpc_cni \
  -target=module.eks_addons.aws_eks_addon.coredns \
  -target=module.eks_addons.aws_eks_addon.kube_proxy \
  -var-file="terraform.tfvars"
```

Verify core addons are running:
```bash
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

kubectl get pods -n kube-system
# coredns pods should be Running

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

Deploy ALB controller next:
```bash
terraform apply \
  -target=module.eks_addons.helm_release.alb_controller \
  -var-file="terraform.tfvars"
```

Deploy everything else (autoscaler + Kubecost):
```bash
terraform apply -var-file="terraform.tfvars"
```

---

## Step 5 — Verify full deployment

```bash
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

# Check all nodes are Ready
kubectl get nodes

# Check all pods across all namespaces
kubectl get pods -A

# Check Kubecost namespace
kubectl get pods -n kubecost

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

---

## Accessing Kubecost

Kubecost runs inside the cluster. Access the dashboard via port-forward:

```bash
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

kubectl port-forward \
  -n kubecost \
  svc/kubecost-cost-analyzer 9090:9090
```

Then open `http://localhost:9090` in your browser.

### What Kubecost shows you

| View | What you see |
|---|---|
| Cost allocation | Spend per namespace, deployment, pod |
| Efficiency | CPU and memory utilisation per pod |
| Savings | Right-sizing recommendations |
| Forecast | Projected monthly spend at current usage |
| Cluster health | Pod restarts, OOM kills, resource pressure |

### Kubecost free tier limits

```
✅ Cost per namespace, deployment, pod
✅ Right-sizing recommendations
✅ 15 days of cost history
✅ Single cluster — sufficient for lean-dev
✅ No credit card, no expiry, no signup
❌ Multi-cluster view (paid)
❌ SSO / SAML (paid)
❌ More than 15 days history (paid)
```

---

## Cost breakdown and savings

### Monthly cost with VPC endpoints

| Resource | Cost |
|---|---|
| EKS control plane | $73.00 |
| 2x t3.medium SPOT nodes | ~$20.00 |
| VPC endpoint — EKS (Interface) | $7.20 |
| VPC endpoint — ECR API (Interface) | $7.20 |
| VPC endpoint — ECR DKR (Interface) | $7.20 |
| VPC endpoint — STS (Interface) | $7.20 |
| VPC endpoint — EC2 (Interface) | $7.20 |
| VPC endpoint — Autoscaling (Interface) | $7.20 |
| VPC endpoint — S3 (Gateway) | FREE |
| Kubecost | FREE |
| Cluster autoscaler | FREE |
| **Total** | **~$136/month** |

### Savings vs common alternatives

| Alternative setup | Monthly cost | Difference |
|---|---|---|
| EKS + NAT Gateway + on-demand nodes | ~$230 | $94 more |
| EKS + NAT Gateway + spot nodes | ~$165 | $29 more |
| EKS + VPC endpoints + spot nodes (this setup) | ~$136 | baseline |
| EKS + public subnets + spot (not recommended) | ~$93 | $43 less but insecure |

### Spot instance savings breakdown

```
t3.medium on-demand price:  $0.0464/hour = ~$34/month per node
t3.medium spot price:       ~$0.014/hour = ~$10/month per node
Saving per node:            ~$24/month
Saving for 2 nodes:         ~$48/month
Saving percentage:          ~70%
```

### Autoscaler savings

The cluster autoscaler scales nodes down to 1 when idle using aggressive settings:

```hcl
scale-down-utilization-threshold = 0.5   # scale down if below 50% used
scale-down-delay-after-add       = 5m    # wait 5 mins after scaling up
scale-down-unneeded-time         = 5m    # remove after 5 mins idle
```

If your cluster sits idle for 8 hours overnight and weekends (~72 hours/week):

```
Idle saving: 1 node removed × $0.014/hour × 72 hours = ~$1/week = ~$4/month
Annual idle saving: ~$48/year from autoscaler alone
```

### CloudWatch log savings

Only two log types enabled instead of all five:

```hcl
enabled_cluster_log_types = ["api", "audit"]
# NOT enabled: authenticator, controllerManager, scheduler
```

```
CloudWatch Logs ingestion: $0.50 per GB
Typical 5-log cluster:     ~$8/month
2-log lean setup:          ~$3/month
Saving:                    ~$5/month = ~$60/year
```

---

## Troubleshooting

### Nodes not joining cluster
```bash
# Check endpoints are available
kubectl get endpoints -n kube-system

# Check node logs
kubectl describe node <node-name>
```

Most common cause is VPC endpoints not yet active — they can take 2-3 minutes to show `available`.

### Kubecost pods not starting
```bash
kubectl describe pod -n kubecost -l app=cost-analyzer
```

Check the pod has enough memory. Kubecost needs ~512Mi on at least one node.

### ALB controller webhook blocking installs
```bash
# List webhooks
kubectl get mutatingwebhookconfigurations

# Delete stuck webhook if present
kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook
```

Then re-run `terraform apply -var-file="terraform.tfvars"`.

### kubectl connecting to localhost:8080
```bash
# kubeconfig not set — run update-kubeconfig after assuming role
eval $(aws sts assume-role \
  --role-arn arn:aws:iam::435321828725:role/OrganizationAccountAccessRole \
  --role-session-name dev-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | \
  awk '{print "export AWS_ACCESS_KEY_ID="$1"\nexport AWS_SECRET_ACCESS_KEY="$2"\nexport AWS_SESSION_TOKEN="$3}')

aws eks update-kubeconfig --name lean-dev --region ap-southeast-2
```

---

## Destroy order

Always destroy in reverse deploy order:

```bash
# Step 1 — EKS cluster and addons
cd environments/dev/eks
terraform destroy -var-file="terraform.tfvars"

# Step 2 — VPC endpoints and VPC
cd environments/dev/vpc
terraform destroy -var-file="terraform.tfvars"
```

To destroy endpoints only without touching the VPC:
```bash
cd environments/dev/vpc
terraform destroy \
  -target=module.vpc_endpoints_workload \
  -var-file="terraform.tfvars"
```

---

## Adding prod EKS in future

Copy the dev EKS environment and change three values:

```bash
cp -r environments/dev/eks environments/prod/eks
```

Update `environments/prod/eks/terraform.tfvars`:
```hcl
workload_account_id = "774386608951"    # prod account
workload_vpc_cidr   = "10.2.0.0/16"    # prod VPC CIDR
cluster_name        = "lean-prod"       # prod cluster name
```

Update `environments/prod/eks/providers.tf` — replace `435321828725` with `774386608951`.

All modules stay unchanged — they are fully reusable.
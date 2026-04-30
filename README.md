# AWS Landing Zone Accelerator — Terraform

A production-ready AWS Landing Zone built with Terraform covering multi-account organisation structure, service control policies, VPC networking with cross-account peering, isolated state management, and continuous IAM policy analysis.

---

## Architecture overview

```
AWS Organization (o-mrik3s6w85) — ap-southeast-2
├── Management account (501562869247)
│   ├── AWS Config (compliance recording)
│   ├── CloudWatch log group (/aws/management/lza-logs)
│   ├── S3 log archive bucket (management-lza-log-archive-501562869247)
│   ├── IAM Access Analyzer (org-wide, free)
│   └── Terraform runs from here
│
├── Workload OU (ou-77xi-o55qljv4)
│   ├── Dev account (435321828725)
│   │   └── Dev VPC (10.0.0.0/16)
│   │       ├── Public subnets  — 10.0.1.0/24, 10.0.2.0/24
│   │       ├── Private AZ-a    — 10.0.3.0/24 · RT-1
│   │       └── Private AZ-b    — 10.0.4.0/24 · RT-2
│   │
│   └── Prod account (774386608951)
│       └── Prod VPC (10.2.0.0/16)
│           ├── Public subnets  — 10.2.1.0/24, 10.2.2.0/24
│           ├── Private AZ-a    — 10.2.3.0/24 · RT-1
│           └── Private AZ-b    — 10.2.4.0/24 · RT-2
│
└── Security OU (ou-77xi-rozu2coh)
    └── Security account (926634327336)
        └── Shared VPC (10.1.0.0/16)
            ├── Public subnets  — 10.1.1.0/24, 10.1.2.0/24
            ├── Private AZ-a    — 10.1.3.0/24 · RT-1
            └── Private AZ-b    — 10.1.4.0/24 · RT-2
```

Dev and prod workload VPCs each peer to the shared security VPC using per-AZ route tables for intra-AZ routing. Dev and prod have no direct peering between them.

---

## What is deployed

| Resource | Account | Cost |
|---|---|---|
| AWS Organizations + OUs | Management | Free |
| Service Control Policies (3) | All OUs | Free |
| FullAWSAccess policy attachment | All OUs | Free |
| AWS Config recorder + IAM role | Management | ~$2–5/month |
| CloudWatch log group (90 day retention) | Management | ~$0.50–2/month |
| S3 log archive bucket (versioned) | Management | ~$0.01/month |
| IAM Access Analyzer (org-wide) | Management | Free |
| Dev VPC + subnets + IGW + route tables | Dev workload | Free |
| Prod VPC + subnets + IGW + route tables | Prod workload | Free |
| Shared security VPC + subnets + IGW | Security | Free |
| VPC peering dev→security | Cross-account | Free |
| VPC peering prod→security | Cross-account | Free |

**Estimated monthly cost: ~$3–8**

---

## Service control policies

Three SCPs are deployed and attached to both the Workload OU and Security OU:

**SCP 1 — Root and org protection**
- Blocks the root user from performing any action in any account
- Prevents accounts from leaving the organization
- Prevents SCPs themselves from being modified or deleted

**SCP 2 — Audit and compliance protection**
- Prevents CloudTrail from being stopped or deleted
- Prevents AWS Config from being stopped or deleted

**SCP 3 — Region and security service protection**
- Blocks all AWS services outside ap-southeast-2
- Exempts global services (IAM, STS, S3, Route53, CloudFront, EC2)
- Prevents disabling future security services if added later

---

## IAM Access Analyzer

Deployed as `type = ORGANIZATION` from the management account — one analyzer covers all accounts in the org. Continuously monitors resource policies and raises findings when any resource is accessible from outside the organization.

**What it scans:** S3 buckets · IAM roles · KMS keys · Lambda functions · SQS queues · Secrets Manager secrets

**Where to view findings:** AWS Console → IAM → Access Analyzer

**Cost:** Permanently free — no trial period, no expiry.

---

## VPC peering design

```
Dev VPC (10.0.0.0/16) ──── peering ────► Shared security VPC (10.1.0.0/16)
Prod VPC (10.2.0.0/16) ─── peering ────► Shared security VPC (10.1.0.0/16)
Dev VPC ──────────────── no peering ──── Prod VPC
```

Per-AZ route tables ensure traffic stays within the same availability zone across the peering connection, avoiding cross-AZ data transfer charges. DNS resolution is enabled across all peering connections.

---

## Terraform state backend

All state files are stored in S3 with DynamoDB locking:

```
tf-state-landing-zone-champ-001/
  aws-lza/management/terraform.tfstate   — org, accounts, SCPs, Config, logging, analyzer
  aws-lza/shared/vpc/terraform.tfstate   — shared security VPC
  aws-lza/dev/vpc/terraform.tfstate      — dev workload VPC
  aws-lza/prod/vpc/terraform.tfstate     — prod workload VPC
  aws-lza/peering/terraform.tfstate      — VPC peering connections
```

Each environment has a completely isolated state file. Destroying one environment never affects another.

---

## Deployment order

Always deploy in this order — each layer depends on the one above it:

```bash
# 1. Foundation — org, accounts, SCPs, Config, logging, IAM analyzer
cd environments/management
terraform init && terraform apply -var-file="terraform.tfvars"

# 2. Shared security VPC — deployed once, used by all environments
cd environments/shared/vpc
terraform init && terraform apply -var-file="terraform.tfvars"

# 3. Dev workload VPC
cd environments/dev/vpc
terraform init && terraform apply -var-file="terraform.tfvars"

# 4. Prod workload VPC
cd environments/prod/vpc
terraform init && terraform apply -var-file="terraform.tfvars"

# 5. VPC peering — must run last, all VPCs must exist first
cd environments/peering
terraform init && terraform apply -var-file="terraform.tfvars"
```

---

## Directory structure

```
environments/
  management/           — org foundation, accounts, SCPs, Config, logging, IAM analyzer
    backend.tf
    main.tf
    providers.tf
    versions.tf
    variables.tf
    terraform.tfvars

  shared/vpc/           — shared security VPC, deployed once
  dev/vpc/              — dev workload VPC only
  prod/vpc/             — prod workload VPC only
  peering/              — VPC peering connections and routes

modules/
  organization/         — AWS Org, OUs, trusted service principals
  accounts/             — member AWS account creation
  scp/                  — service control policies and attachments
  config/               — AWS Config recorder and IAM role
  logging/              — CloudWatch log group and S3 archive
  vpc/                  — VPC, subnets, IGW, per-AZ route tables
  vpc-peering/          — peering connection, auto-accept, routes, DNS
  iam-analyzer/         — IAM Access Analyzer (org-wide)
```

---

## Useful commands

```bash
# Check current state of all resources
terraform show

# List all resources Terraform is managing
terraform state list

# Preview changes without applying
terraform plan -var-file="terraform.tfvars"

# Format all .tf files
terraform fmt

# Destroy a specific environment only
terraform destroy -var-file="terraform.tfvars"
```

---

## Security notes

- `terraform.tfvars` files are excluded by `.gitignore` — never commit them as they contain account IDs and email addresses
- The `OrganizationAccountAccessRole` created in each member account allows the management account to assume role into member accounts for Terraform deployments
- SCPs are enforced at the OU level — all accounts inside an OU inherit all attached SCPs automatically
- The `FullAWSAccess` policy is attached at the OU level as the baseline allow — SCPs then deny specific actions on top of it
- VPC peering uses `auto_accept = true` which is safe as both accounts are within the same AWS Organization

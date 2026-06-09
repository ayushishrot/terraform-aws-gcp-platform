# terraform-aws-gcp-platform

[![Terraform](https://img.shields.io/badge/Terraform-1.7+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20RDS%20%7C%20IAM-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![GCP](https://img.shields.io/badge/GCP-GKE-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)](https://cloud.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

A reusable, multi-cloud **Terraform module library** for standing up production-grade
infrastructure on **AWS** and **GCP** from the same composition layer. Built to
standardize environment provisioning, cut deployment turnaround, and keep dev and prod
configuration-identical apart from sizing.

> Mirrors the multi-cloud Terraform module work I do day-to-day as a Senior SRE:
> reusable modules, remote state, least-privilege IAM, and a `validate` gate in CI.

## Architecture

```mermaid
flowchart TB
    subgraph composition["environments/ (composition layer)"]
        dev["dev"]
        prod["prod"]
    end

    subgraph aws["AWS modules"]
        vpc["aws-vpc"]
        eks["aws-eks"]
        rds["aws-rds"]
        alb["aws-alb"]
        irsa["aws-iam-irsa"]
    end

    subgraph gcp["GCP modules"]
        gke["gcp-gke"]
    end

    dev --> vpc & eks & rds & alb & irsa & gke
    prod --> vpc & eks & rds & alb & irsa & gke
    vpc --> eks
    vpc --> rds
    eks --> irsa
    eks --> alb

    state[("Remote state\nS3 + DynamoDB lock")]
    composition -.->|backend| state
```

## What's inside

| Module | Cloud | Purpose |
|--------|-------|---------|
| `modules/aws-vpc` | AWS | VPC with public/private subnets across 3 AZs, NAT, flow logs |
| `modules/aws-eks` | AWS | EKS cluster + managed node groups, OIDC provider, autoscaling tags |
| `modules/aws-rds` | AWS | Multi-AZ Postgres/MySQL, encrypted, secret in Secrets Manager |
| `modules/aws-alb` | AWS | Application Load Balancer + target groups + WAF association |
| `modules/aws-iam-irsa` | AWS | Least-privilege IRSA roles for in-cluster workloads |
| `modules/gcp-gke` | GCP | Regional GKE cluster with Workload Identity + autoscaling node pools |

## Usage

```hcl
# environments/dev/main.tf
module "vpc" {
  source   = "../../modules/aws-vpc"
  name     = "compliance-dev"
  cidr     = "10.20.0.0/16"
  az_count = 3
  tags     = local.tags
}

module "eks" {
  source             = "../../modules/aws-eks"
  cluster_name       = "compliance-dev"
  kubernetes_version = "1.29"
  subnet_ids         = module.vpc.private_subnet_ids
  node_groups = {
    general = { instance_types = ["t3.large"], min = 2, max = 6, desired = 3 }
  }
  tags = local.tags
}
```

```bash
cd environments/dev
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Conventions

- **Remote state** in S3 with a DynamoDB lock table (`environments/*/backend.tf`).
- **Least privilege**  IAM via IRSA, no node-wide policies; RDS credentials live in Secrets Manager, never in state output as plaintext.
- **Tagging**  every resource carries `Environment`, `Owner`, `ManagedBy=terraform`, `CostCenter`.
- **`terraform fmt` + `validate`** enforced in CI on every PR (`.github/workflows/terraform.yml`).

## Repo layout

```
modules/        # reusable building blocks (one concern each)
environments/   # dev + prod compositions wiring modules together
examples/       # minimal runnable example per module
```

## License

MIT © Ayushi Shrotriya

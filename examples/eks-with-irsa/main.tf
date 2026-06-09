terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source   = "../../modules/aws-vpc"
  name     = "demo"
  cidr     = "10.42.0.0/16"
  az_count = 2
}

module "eks" {
  source             = "../../modules/aws-eks"
  cluster_name       = "demo"
  kubernetes_version = "1.29"
  subnet_ids         = module.vpc.private_subnet_ids
  node_groups = {
    general = { instance_types = ["t3.medium"], min = 1, max = 3, desired = 2 }
  }
}

# Bind the "external-dns" ServiceAccount to a least-privilege Route53 role.
module "external_dns_irsa" {
  source            = "../../modules/aws-iam-irsa"
  role_name         = "demo-external-dns"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  namespace         = "kube-system"
  service_account   = "external-dns"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
        Resource = ["*"]
      }
    ]
  })
}

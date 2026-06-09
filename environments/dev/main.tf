terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

locals {
  env = "dev"
  tags = {
    Environment = local.env
    Owner       = "platform-sre"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
  }
}

module "vpc" {
  source             = "../../modules/aws-vpc"
  name               = "compliance-${local.env}"
  cidr               = "10.20.0.0/16"
  az_count           = 3
  single_nat_gateway = true # cost-optimized for dev
  tags               = local.tags
}

# Security group representing the in-cluster app tier allowed to reach RDS.
module "app_sg" {
  source = "../../modules/app-sg"
  name   = "compliance-${local.env}-app"
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

module "eks" {
  source                 = "../../modules/aws-eks"
  cluster_name           = "compliance-${local.env}"
  kubernetes_version     = "1.29"
  subnet_ids             = module.vpc.private_subnet_ids
  endpoint_public_access = true
  public_access_cidrs    = ["0.0.0.0/0"]
  node_groups = {
    general = {
      instance_types = ["t3.large"]
      min            = 2
      max            = 6
      desired        = 3
    }
    spot = {
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "SPOT"
      min            = 0
      max            = 8
      desired        = 2
      labels         = { workload = "batch" }
    }
  }
  tags = local.tags
}

module "rds" {
  source                     = "../../modules/aws-rds"
  identifier                 = "compliance-${local.env}"
  engine                     = "postgres"
  instance_class             = "db.t3.medium"
  db_name                    = "compliance"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.app_sg.id]
  multi_az                   = false
  deletion_protection        = false
  tags                       = local.tags
}

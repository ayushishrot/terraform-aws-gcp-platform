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
  env = "prod"
  tags = {
    Environment = local.env
    Owner       = "platform-sre"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Compliance  = "soc2-iso27001"
  }
}

module "vpc" {
  source             = "../../modules/aws-vpc"
  name               = "compliance-${local.env}"
  cidr               = "10.10.0.0/16"
  az_count           = 3
  single_nat_gateway = false # one NAT per AZ for HA
  tags               = local.tags
}

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
  endpoint_public_access = false # private API endpoint in prod
  node_groups = {
    general = {
      instance_types = ["m6i.xlarge"]
      min            = 3
      max            = 12
      desired        = 4
    }
  }
  tags = local.tags
}

module "rds" {
  source                     = "../../modules/aws-rds"
  identifier                 = "compliance-${local.env}"
  engine                     = "postgres"
  instance_class             = "db.r6g.large"
  allocated_storage          = 100
  max_allocated_storage      = 500
  db_name                    = "compliance"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.app_sg.id]
  multi_az                   = true
  backup_retention_period    = 30
  deletion_protection        = true
  tags                       = local.tags
}

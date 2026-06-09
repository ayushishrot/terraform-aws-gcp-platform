terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

# Minimal security group used as the "app tier" identity that is allowed
# to reach data stores (RDS, ElastiCache, etc.).
resource "aws_security_group" "this" {
  name        = var.name
  description = "App tier security group for ${var.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { ManagedBy = "terraform", Module = "app-sg" })
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

output "id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

# IRSA: bind a Kubernetes ServiceAccount to a least-privilege IAM role
# via the cluster's OIDC provider. No node-wide permissions.

locals {
  oidc_host   = replace(var.oidc_provider_url, "https://", "")
  common_tags = merge(var.tags, { ManagedBy = "terraform", Module = "aws-iam-irsa" })
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "this" {
  count       = var.policy_json == null ? 0 : 1
  name        = "${var.role_name}-policy"
  description = "Least-privilege policy for ${var.service_account}"
  policy      = var.policy_json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "inline" {
  count      = var.policy_json == null ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster IAM OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster OIDC issuer"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name to bind"
  type        = string
}

variable "policy_json" {
  description = "Inline least-privilege IAM policy document (JSON). Null to skip."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name for the ALB and related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal-only"
  type        = bool
  default     = false
}

variable "ingress_cidrs" {
  description = "CIDRs allowed to reach the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_port" {
  description = "Port the target group forwards to"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP health-check path"
  type        = string
  default     = "/healthz"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}

variable "waf_acl_arn" {
  description = "Optional WAFv2 Web ACL ARN to associate"
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

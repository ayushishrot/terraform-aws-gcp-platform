variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes control-plane version"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the cluster and node groups"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the API server endpoint is publicly reachable"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint (when enabled)"
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = "Map of managed node groups"
  type = map(object({
    instance_types = list(string)
    min            = number
    max            = number
    desired        = number
    capacity_type  = optional(string, "ON_DEMAND")
    labels         = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

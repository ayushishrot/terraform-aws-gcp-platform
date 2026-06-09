variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region for the regional cluster"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "VPC network self-link or name"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self-link or name"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR for the private control plane"
  type        = string
  default     = "172.16.0.0/28"
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}

variable "node_pools" {
  description = "Map of node pools"
  type = map(object({
    machine_type = string
    min          = number
    max          = number
    disk_size_gb = optional(number, 100)
  }))
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}

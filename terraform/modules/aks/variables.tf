variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS API server."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used by the AKS node pool."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  type        = string
}

variable "acr_id" {
  description = "Azure Container Registry ID."
  type        = string
}

variable "node_count" {
  description = "AKS system node count."
  type        = number
}

variable "node_vm_size" {
  description = "AKS node VM size."
  type        = string
}

variable "kubernetes_version" {
  description = "Optional AKS version."
  type        = string
  default     = null
  nullable    = true
}

variable "service_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
}

variable "dns_service_ip" {
  description = "Kubernetes DNS IP."
  type        = string
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR."
  type        = string
}

variable "authorized_ip_ranges" {
  description = "Optional authorized IP ranges for the AKS API server."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to AKS resources."
  type        = map(string)
  default     = {}
}

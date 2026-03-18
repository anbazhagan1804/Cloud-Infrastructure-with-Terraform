variable "project_name" {
  description = "Short project name used for Azure resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "project_name can contain only letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name such as dev, test, or prod."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the platform virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "aks_subnet_address_prefixes" {
  description = "Subnet CIDR blocks used by the AKS node pool."
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "node_count" {
  description = "Initial AKS system node count."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "kubernetes_version" {
  description = "Optional AKS version. Leave null to use the Azure default."
  type        = string
  default     = null
  nullable    = true
}

variable "service_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
  default     = "10.21.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP from the service CIDR."
  type        = string
  default     = "10.21.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR for AKS."
  type        = string
  default     = "172.17.0.1/16"
}

variable "authorized_ip_ranges" {
  description = "Optional public IP ranges allowed to reach the AKS API server."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

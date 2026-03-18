variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual network address spaces."
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "AKS subnet name."
  type        = string
}

variable "aks_subnet_address_prefixes" {
  description = "AKS subnet CIDR ranges."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

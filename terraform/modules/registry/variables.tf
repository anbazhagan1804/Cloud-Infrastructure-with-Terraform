variable "name_prefix" {
  description = "Prefix used to derive a globally unique registry name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags applied to the registry."
  type        = map(string)
  default     = {}
}

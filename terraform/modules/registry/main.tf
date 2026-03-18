resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  sanitized_prefix = regexreplace(lower(var.name_prefix), "[^0-9a-z]", "")
  registry_name    = substr("${local.sanitized_prefix}${random_string.suffix.result}", 0, 50)
}

resource "azurerm_container_registry" "this" {
  name                = local.registry_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags
}

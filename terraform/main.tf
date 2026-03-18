module "resource_group" {
  source = "./modules/resource_group"

  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "./modules/network"

  resource_group_name         = module.resource_group.name
  location                    = module.resource_group.location
  vnet_name                   = "vnet-${local.name_prefix}"
  vnet_address_space          = var.vnet_address_space
  aks_subnet_name             = "snet-aks-${local.name_prefix}"
  aks_subnet_address_prefixes = var.aks_subnet_address_prefixes
  tags                        = local.common_tags
}

module "observability" {
  source = "./modules/observability"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "log-${replace(local.name_prefix, "-", "")}"
  retention_in_days   = 30
  tags                = local.common_tags
}

module "registry" {
  source = "./modules/registry"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name_prefix         = local.name_prefix
  sku                 = "Basic"
  tags                = local.common_tags
}

module "aks" {
  source = "./modules/aks"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  cluster_name               = "aks-${local.name_prefix}"
  dns_prefix                 = replace(local.name_prefix, "-", "")
  subnet_id                  = module.network.aks_subnet_id
  log_analytics_workspace_id = module.observability.workspace_id
  acr_id                     = module.registry.id
  node_count                 = var.node_count
  node_vm_size               = var.node_vm_size
  kubernetes_version         = var.kubernetes_version
  service_cidr               = var.service_cidr
  dns_service_ip             = var.dns_service_ip
  docker_bridge_cidr         = var.docker_bridge_cidr
  authorized_ip_ranges       = var.authorized_ip_ranges
  tags                       = local.common_tags
}

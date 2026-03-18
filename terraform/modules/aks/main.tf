resource "tls_private_key" "aks_admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  scope                            = var.subnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  role_based_access_control_enabled = true
  local_account_disabled            = false
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  sku_tier                          = "Free"

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    node_count           = var.node_count
    vnet_subnet_id       = var.subnet_id
    orchestrator_version = var.kubernetes_version
    type                 = "VirtualMachineScaleSets"
    max_pods             = 30
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = trimspace(tls_private_key.aks_admin.public_key_openssh)
    }
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.authorized_ip_ranges) == 0 ? [] : [var.authorized_ip_ranges]

    content {
      authorized_ip_ranges = api_server_access_profile.value
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.subnet_network_contributor
  ]
}

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

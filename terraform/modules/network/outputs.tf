output "vnet_id" {
  description = "Virtual network resource ID."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "AKS subnet resource ID."
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
  description = "AKS subnet name."
  value       = azurerm_subnet.aks.name
}

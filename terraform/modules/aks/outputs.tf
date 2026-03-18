output "id" {
  description = "AKS cluster ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "AKS API server FQDN."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_object_id" {
  description = "Kubelet managed identity object ID."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID for the AKS user-assigned identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "generated_ssh_public_key" {
  description = "Generated SSH public key used for node access."
  value       = trimspace(tls_private_key.aks_admin.public_key_openssh)
}

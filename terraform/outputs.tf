output "resource_group_name" {
  description = "Platform resource group name."
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "aks_cluster_fqdn" {
  description = "AKS public API server FQDN."
  value       = module.aks.fqdn
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity integrations."
  value       = module.aks.oidc_issuer_url
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.registry.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.registry.login_server
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.observability.workspace_id
}

output "kubectl_credentials_command" {
  description = "Command to fetch admin kubeconfig for the AKS cluster."
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.name} --admin --overwrite-existing"
}

output "publish_demo_image_command" {
  description = "PowerShell command to build the demo app image and push it to ACR."
  value       = ".\\scripts\\publish-demo-image.ps1 -AcrLoginServer ${module.registry.login_server} -ImageTag latest"
}

output "argocd_bootstrap_command" {
  description = "PowerShell command to install Argo CD and apply the root GitOps application."
  value       = ".\\scripts\\bootstrap-argocd.ps1 -AksResourceGroup ${module.resource_group.name} -AksClusterName ${module.aks.name} -AcrLoginServer ${module.registry.login_server} -GitHubToken <github-pat> -GitOpsRepoUrl <your-gitops-repo-url> -ImageTag latest"
}

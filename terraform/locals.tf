locals {
  name_prefix = lower("${var.project_name}-${var.environment}")

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
      workload    = "aks-platform"
    },
    var.tags
  )
}

param(
    [Parameter(Mandatory = $true)]
    [string]$AksResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$AksClusterName,

    [Parameter(Mandatory = $true)]
    [string]$GitOpsRepoUrl,

    [Parameter(Mandatory = $true)]
    [string]$AcrLoginServer,

    [Parameter(Mandatory = $false)]
    [string]$ImageTag = "latest",

    [Parameter(Mandatory = $false)]
    [string]$ArgocdNamespace = "argocd"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

foreach ($command in @("az", "helm", "kubectl")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required. Install it first, then rerun this script."
    }
}

& (Join-Path $PSScriptRoot "configure-gitops.ps1") `
    -GitOpsRepoUrl $GitOpsRepoUrl `
    -AcrLoginServer $AcrLoginServer `
    -ImageTag $ImageTag

az aks get-credentials `
    --resource-group $AksResourceGroup `
    --name $AksClusterName `
    --admin `
    --overwrite-existing | Out-Null

helm repo add argo https://argoproj.github.io/argo-helm --force-update | Out-Null
helm repo update | Out-Null

helm upgrade --install argocd argo/argo-cd `
    --namespace $ArgocdNamespace `
    --create-namespace `
    --values (Join-Path $repoRoot "gitops\\bootstrap\\argocd-values.yaml") `
    --wait `
    --timeout 10m | Out-Null

kubectl rollout status deployment/argocd-server -n $ArgocdNamespace --timeout=300s
kubectl rollout status deployment/argocd-applicationset-controller -n $ArgocdNamespace --timeout=300s
kubectl apply -f (Join-Path $repoRoot "gitops\\bootstrap\\root-application.yaml")

Write-Host "Argo CD bootstrap complete."
kubectl get applications -n $ArgocdNamespace
kubectl get svc -n $ArgocdNamespace

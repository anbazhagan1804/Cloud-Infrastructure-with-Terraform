param(
    [Parameter(Mandatory = $true)]
    [string]$AksResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$AksClusterName
)

$ErrorActionPreference = "Stop"

foreach ($command in @("az", "kubectl")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required. Install it first, then rerun this script."
    }
}

az aks get-credentials `
    --resource-group $AksResourceGroup `
    --name $AksClusterName `
    --admin `
    --overwrite-existing | Out-Null

Write-Host "AKS admin credentials were added to your kubeconfig."
kubectl cluster-info

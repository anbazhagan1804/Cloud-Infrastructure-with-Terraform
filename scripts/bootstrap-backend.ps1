param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-tfstate-shared",

    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $false)]
    [string]$ContainerName = "tfstate",

    [Parameter(Mandatory = $false)]
    [string]$StateKey = "cloud-terraform/dev.tfstate"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install az first, then rerun this script."
}

if (-not $StorageAccountName) {
    $randomSuffix = -join ((48..57) + (97..122) | Get-Random -Count 10 | ForEach-Object { [char]$_ })
    $StorageAccountName = ("tfstate" + $randomSuffix).ToLower()
}

Write-Host "Using storage account: $StorageAccountName"
az account set --subscription $SubscriptionId | Out-Null

az group create `
    --name $ResourceGroupName `
    --location $Location | Out-Null

az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false | Out-Null

$storageKey = az storage account keys list `
    --resource-group $ResourceGroupName `
    --account-name $StorageAccountName `
    --query "[0].value" `
    --output tsv

az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --account-key $storageKey `
    --auth-mode key | Out-Null

Write-Host ""
Write-Host "Copy this into terraform\\envs\\dev\\backend.hcl"
Write-Host "resource_group_name  = `"$ResourceGroupName`""
Write-Host "storage_account_name = `"$StorageAccountName`""
Write-Host "container_name       = `"$ContainerName`""
Write-Host "key                  = `"$StateKey`""
Write-Host "use_azuread_auth     = true"

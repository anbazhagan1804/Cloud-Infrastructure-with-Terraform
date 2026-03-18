param(
    [Parameter(Mandatory = $false)]
    [string]$AcrName,

    [Parameter(Mandatory = $true)]
    [string]$AcrLoginServer,

    [Parameter(Mandatory = $false)]
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

foreach ($command in @("az", "docker")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required. Install it first, then rerun this script."
    }
}

if (-not $AcrName) {
    $AcrName = ($AcrLoginServer -split "\\.")[0]
}

$imageRepository = "$AcrLoginServer/cloudtf-demo"
$imageReference = "$imageRepository`:$ImageTag"

az acr login --name $AcrName | Out-Null

docker build `
    --tag $imageReference `
    --file (Join-Path $repoRoot "app\\Dockerfile") `
    (Join-Path $repoRoot "app")

if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed."
}

docker push $imageReference

if ($LASTEXITCODE -ne 0) {
    throw "Docker push failed."
}

& (Join-Path $PSScriptRoot "set-demo-image.ps1") `
    -ImageRepository $imageRepository `
    -ImageTag $ImageTag

Write-Host "Published demo image: $imageReference"

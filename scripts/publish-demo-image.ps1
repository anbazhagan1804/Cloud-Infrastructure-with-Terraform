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
$tagsToPush = @($ImageTag)
if ($ImageTag -ne "latest") {
    $tagsToPush += "latest"
}

az acr login --name $AcrName | Out-Null

docker build `
    --tag "$imageRepository`:$ImageTag" `
    --file (Join-Path $repoRoot "app\\Dockerfile") `
    (Join-Path $repoRoot "app")

if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed."
}

foreach ($tag in $tagsToPush) {
    $reference = "$imageRepository`:$tag"
    if ($tag -ne $ImageTag) {
        docker tag "$imageRepository`:$ImageTag" $reference
        if ($LASTEXITCODE -ne 0) {
            throw "Docker tag failed for $reference."
        }
    }

    docker push $reference
    if ($LASTEXITCODE -ne 0) {
        throw "Docker push failed for $reference."
    }
}

Write-Host "Published demo image: $imageRepository`:$ImageTag"

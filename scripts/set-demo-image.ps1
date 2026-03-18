param(
    [Parameter(Mandatory = $true)]
    [string]$ImageRepository,

    [Parameter(Mandatory = $false)]
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$overlayFile = Join-Path $repoRoot "gitops\\workloads\\demo\\overlays\\dev\\kustomization.yaml"

$content = Get-Content -Raw -Path $overlayFile
$content = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    "(?m)^(\s*newName:\s*).+$",
    "`$1$ImageRepository"
)
$content = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    "(?m)^(\s*newTag:\s*).+$",
    "`$1$ImageTag"
)

Set-Content -Path $overlayFile -Value $content -Encoding ascii
Write-Host "Updated demo image to $ImageRepository`:$ImageTag"

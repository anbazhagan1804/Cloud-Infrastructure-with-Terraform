param(
    [Parameter(Mandatory = $true)]
    [string]$GitOpsRepoUrl,

    [Parameter(Mandatory = $false)]
    [string]$AcrLoginServer,

    [Parameter(Mandatory = $false)]
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestFiles = @(
    (Join-Path $repoRoot "gitops\\bootstrap\\root-application.yaml"),
    (Join-Path $repoRoot "gitops\\apps\\demo-app.yaml")
)

foreach ($file in $manifestFiles) {
    $content = Get-Content -Raw -Path $file
    $updated = [System.Text.RegularExpressions.Regex]::Replace(
        $content,
        "(?m)^(\s*repoURL:\s*).+$",
        "`$1$GitOpsRepoUrl"
    )
    Set-Content -Path $file -Value $updated -Encoding ascii
}

if ($AcrLoginServer) {
    & (Join-Path $PSScriptRoot "set-demo-image.ps1") `
        -ImageRepository "$AcrLoginServer/cloudtf-demo" `
        -ImageTag $ImageTag
}

Write-Host "Updated GitOps manifests with repository URL: $GitOpsRepoUrl"

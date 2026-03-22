param(
    [Parameter(Mandatory = $false)]
    [string]$GitOpsRepoUrl,

    [Parameter(Mandatory = $false)]
    [string]$AcrLoginServer,

    [Parameter(Mandatory = $false)]
    [string]$ImageTag = "latest",

    [Parameter(Mandatory = $true)]
    [string]$GitHubToken,

    [Parameter(Mandatory = $false)]
    [string]$CommitMessage = "chore: update GitOps image reference"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required. Install it first, then rerun this script."
}

if ($GitOpsRepoUrl) {
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
}

if ($AcrLoginServer) {
    & (Join-Path $PSScriptRoot "set-demo-image.ps1") `
        -ImageRepository "$AcrLoginServer/cloudtf-demo" `
        -ImageTag $ImageTag
}

$gitUserName = git config user.name
if (-not $gitUserName) {
    git config user.name "Azure DevOps"
}

$gitUserEmail = git config user.email
if (-not $gitUserEmail) {
    git config user.email "azuredevops@local"
}

$gitStatus = git status --porcelain -- gitops/bootstrap/root-application.yaml gitops/apps/demo-app.yaml gitops/workloads/demo/overlays/dev/kustomization.yaml
if ($LASTEXITCODE -ne 0) {
    throw "Failed to inspect git status."
}

if ($gitStatus) {
    git add gitops/bootstrap/root-application.yaml gitops/apps/demo-app.yaml gitops/workloads/demo/overlays/dev/kustomization.yaml
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage GitOps manifest changes."
    }

    git commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit GitOps manifest changes."
    }

    $originUrl = git remote get-url origin
    if ($LASTEXITCODE -ne 0 -or -not $originUrl) {
        throw "Failed to determine the git remote URL."
    }

    $pushUrl = switch -Regex ($originUrl) {
        '^https://github.com/(.+)$' {
            "https://x-access-token:$GitHubToken@github.com/$($Matches[1])"
            break
        }
        '^git@github.com:(.+)$' {
            "https://x-access-token:$GitHubToken@github.com/$($Matches[1])"
            break
        }
        '^ssh://git@github.com/(.+)$' {
            "https://x-access-token:$GitHubToken@github.com/$($Matches[1])"
            break
        }
        default {
            throw "Unsupported git remote URL format. Use a GitHub HTTPS or SSH remote."
        }
    }

    git push $pushUrl HEAD:main
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push GitOps manifest changes."
    }

    Write-Host "Updated and pushed GitOps manifests."
}
else {
    Write-Host "No GitOps manifest changes were needed."
}

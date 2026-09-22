# Automatically deploys the updated ToolWizFusionAddin to Autodesk Fusion's InternalAddins folder
$ErrorActionPreference = "Stop"

$src = Join-Path $PSScriptRoot "ToolWizFusionAddin"
$fusionInternalBase = "$HOME\AppData\Local\Autodesk\webdeploy\production"

$targetDirs = Get-ChildItem -Path $fusionInternalBase -Directory -Filter "Api" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Where-Object {
    Test-Path (Join-Path $_.FullName "InternalAddins")
}

if (-not $targetDirs) {
    # Fallback to direct search for existing ToolWizFusionAddin
    $existing = Get-ChildItem -Path $fusionInternalBase -Filter "ToolWizFusionAddin.manifest" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existing) {
        $dest = $existing.Directory.FullName
    } else {
        Write-Error "Could not find Fusion 360 InternalAddins directory."
        exit 1
    }
} else {
    $dest = Join-Path $targetDirs[0].FullName "InternalAddins\ToolWizFusionAddin"
}

Write-Host "Deploying ToolWizFusionAddin to: $dest" -ForegroundColor Cyan
if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
Remove-Item -Path (Join-Path $dest "__pycache__") -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "ToolWizFusionAddin successfully deployed to Fusion 360!" -ForegroundColor Green
Write-Host "In Fusion 360: Go to Utilities > Scripts and Add-ins > Add-ins tab, Stop 'ToolWizFusionAddin', and click Run." -ForegroundColor Yellow

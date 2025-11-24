<#
.SYNOPSIS
  Build and push SAIF v2 API container and restart app
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("germanywestcentral","swedencentral")]
  [string]$location = "germanywestcentral",
  [Parameter(Mandatory=$false)]
  [string]$resourceGroupName,
  [Parameter(Mandatory=$false, HelpMessage="Update API container")]
  [switch]$buildApi,
  [Parameter(Mandatory=$false, HelpMessage="Update Web container")]
  [switch]$buildWeb
)

function Show-Banner { param([string]$m); $b = "=" * ($m.Length + 4); Write-Host "`n$b" -ForegroundColor Cyan; Write-Host "| $m |" -ForegroundColor White -BackgroundColor DarkBlue; Write-Host $b -ForegroundColor Cyan; Write-Host "" }

if (-not $resourceGroupName) { $resourceGroupName = ($location -eq 'swedencentral') ? 'rg-saifv2-swc01' : 'rg-saifv2-gwc01' }

try { $acct = az account show --query "{name:name, user:user.name, id:id}" -o json | ConvertFrom-Json } catch { Write-Host "Please run 'az login'" -ForegroundColor Red; exit 1 }

Show-Banner "SAIF v2 - Update Containers"

# Get latest deployment outputs
$dep = az deployment group list --resource-group $resourceGroupName --query "[?contains(name, 'main-v2-')]|[0].name" -o tsv
if (-not $dep) { Write-Host "No v2 deployment found" -ForegroundColor Red; exit 1 }
$outs = az deployment group show --resource-group $resourceGroupName --name $dep --query properties.outputs -o json | ConvertFrom-Json
$acrName = $outs.acrName.value
$apiApp = $outs.apiAppServiceName.value
$webApp = $outs.webAppServiceName.value

# If neither switch is provided, ask the user which containers to update
if (-not $buildApi -and -not $buildWeb) {
  Write-Host "Which container(s) do you want to update?" -ForegroundColor Cyan
  Write-Host "  1) API" -ForegroundColor Gray
  Write-Host "  2) Web" -ForegroundColor Gray
  Write-Host "  3) Both" -ForegroundColor Gray
  $choice = Read-Host "Enter choice [3]"
  switch ($choice) {
    '1' { $buildApi = $true }
    '2' { $buildWeb = $true }
    '3' { $buildApi = $true; $buildWeb = $true }
    default {
      # Also allow free text like 'api', 'web', 'both'; default to both
      if ($choice -match 'api') { $buildApi = $true }
      if ($choice -match 'web') { $buildWeb = $true }
      if ($choice -match 'both') { $buildApi = $true; $buildWeb = $true }
      if (-not $buildApi -and -not $buildWeb) { $buildApi = $true; $buildWeb = $true }
    }
  }
}

# Resolve build contexts relative to this script's directory so it works from any CWD
$apiContext = Join-Path -Path $PSScriptRoot -ChildPath '..\api-v2'
$webContext = Join-Path -Path $PSScriptRoot -ChildPath '..\web'

if ($buildApi -and -not (Test-Path $apiContext)) { Write-Host "API context not found at: $apiContext" -ForegroundColor Red; exit 1 }
if ($buildWeb -and -not (Test-Path $webContext)) { Write-Host "Web context not found at: $webContext" -ForegroundColor Red; exit 1 }

if ($buildApi) {
  az acr build --registry $acrName --image saifv2/api:latest $apiContext
  if ($LASTEXITCODE -ne 0) { Write-Host "API v2 image build failed" -ForegroundColor Red; exit 1 }
}
if ($buildWeb) {
  az acr build --registry $acrName --image saif/web:latest $webContext
  if ($LASTEXITCODE -ne 0) { Write-Host "Web image build failed" -ForegroundColor Red; exit 1 }
}

if ($buildApi) { az webapp restart --name $apiApp --resource-group $resourceGroupName | Out-Null }
if ($buildWeb) { az webapp restart --name $webApp --resource-group $resourceGroupName | Out-Null }

# Build a friendly summary without casting switch parameters
$updated = @()
if ($buildApi) { $updated += 'API' }
if ($buildWeb) { $updated += 'Web' }
if ($updated.Count -eq 0) { $updated = @('None') }
Write-Host ("✅ Updated and restarted: " + ($updated -join ", ")) -ForegroundColor Green

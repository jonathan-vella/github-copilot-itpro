# cleanup.ps1 - Remove Azure Infrastructure
# Purpose: Deletes the resource group and all deployed resources
# Usage: .\cleanup.ps1 -ResourceGroupName "rg-taskmanager-prod"

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   ⚠️  INFRASTRUCTURE CLEANUP WARNING                          ║
╚═══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Red

Write-Host "You are about to DELETE the following:" -ForegroundColor Yellow
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   All contained resources (VMs, databases, networks, etc.)" -ForegroundColor White
Write-Host "`n   This action is IRREVERSIBLE!`n" -ForegroundColor Red

# Check if resource group exists
try {
    $rgExists = az group exists --name $ResourceGroupName --output tsv
    
    if ($rgExists -eq 'false') {
        Write-Host "❌ Resource group '$ResourceGroupName' does not exist" -ForegroundColor Yellow
        exit 0
    }
}
catch {
    Write-Host "❌ Error checking resource group: $_" -ForegroundColor Red
    exit 1
}

# Get resource count
try {
    $resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
    $resourceCount = $resources.Count
    
    Write-Host "📦 Resources to be deleted: $resourceCount`n" -ForegroundColor Cyan
    $resources | Group-Object type | ForEach-Object {
        Write-Host "   • $($_.Name): $($_.Count)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "⚠️  Could not retrieve resource list" -ForegroundColor Yellow
}

# Confirmation
if (-not $Force) {
    Write-Host "`n"
    $confirmation = Read-Host "Type 'DELETE' to confirm deletion"
    
    if ($confirmation -ne 'DELETE') {
        Write-Host "`n✅ Cleanup cancelled. No resources were deleted." -ForegroundColor Green
        exit 0
    }
}

# Delete resource group
Write-Host "`n🗑️  Deleting resource group..." -ForegroundColor Cyan
Write-Host "   This may take several minutes...`n" -ForegroundColor Gray

$startTime = Get-Date

try {
    az group delete --name $ResourceGroupName --yes --no-wait
    
    Write-Host "✅ Deletion initiated successfully" -ForegroundColor Green
    Write-Host "`n   Resource group '$ResourceGroupName' is being deleted in the background." -ForegroundColor Gray
    Write-Host "   You can check the status in Azure Portal.`n" -ForegroundColor Gray
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   ✅ CLEANUP COMPLETED                                        ║
╚═══════════════════════════════════════════════════════════════╝

Resource group deletion initiated: $ResourceGroupName
Duration: $($duration.TotalSeconds) seconds

The deletion will complete in the background.
Check Azure Portal for final status.

"@ -ForegroundColor Green
}
catch {
    Write-Host "❌ Cleanup failed: $_" -ForegroundColor Red
    exit 1
}

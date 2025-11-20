<#
.SYNOPSIS
    Clean up the Bicep Quickstart demo infrastructure from Azure.

.DESCRIPTION
    This script deletes the resource group and all resources created by the
    Bicep Quickstart demo. It provides confirmation prompts to prevent
    accidental deletion.

.PARAMETER ResourceGroupName
    Name of the Azure resource group to delete.

.PARAMETER Force
    Skip confirmation prompts and delete immediately.

.EXAMPLE
    .\cleanup.ps1 -ResourceGroupName "rg-copilot-demo"

.EXAMPLE
    .\cleanup.ps1 -ResourceGroupName "rg-copilot-demo" -Force

.NOTES
    Author: GitHub Copilot Demo
    Prerequisites:
    - Azure CLI installed and logged in
    - Appropriate Azure permissions (Contributor or Owner on resource group)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Set strict mode and error action preference
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Colors for output
$ColorSuccess = 'Green'
$ColorWarning = 'Yellow'
$ColorError = 'Red'
$ColorInfo = 'Cyan'

#region Helper Functions

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n▶ $Message" -Color $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" -Color $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" -Color $ColorWarning
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" -Color $ColorError
}

#endregion

#region Main Script

try {
    Write-ColorOutput @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║    Bicep Quickstart Demo - Resource Cleanup                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@ -Color $ColorInfo

    # Step 1: Check Azure login
    Write-Step "Verifying Azure login..."
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-ErrorMessage "Not logged into Azure. Please run: az login"
        exit 1
    }
    Write-Success "Logged in as: $($account.user.name)"
    Write-Success "Subscription: $($account.name) ($($account.id))"

    # Step 2: Check if resource group exists
    Write-Step "Checking resource group: $ResourceGroupName..."
    
    $rgExists = az group exists --name $ResourceGroupName --output tsv
    if ($rgExists -ne 'true') {
        Write-Warning "Resource group '$ResourceGroupName' does not exist. Nothing to clean up."
        exit 0
    }

    # Step 3: Get resource group details
    $rg = az group show --name $ResourceGroupName --output json | ConvertFrom-Json
    Write-Success "Resource group found"
    Write-Host "  Location: $($rg.location)"
    Write-Host "  Tags: $($rg.tags | ConvertTo-Json -Compress)"

    # Step 4: List resources in the group
    Write-Step "Listing resources in the group..."
    $resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
    
    if ($resources.Count -eq 0) {
        Write-Warning "No resources found in the group"
    } else {
        Write-Host "`nResources to be deleted:"
        $resources | ForEach-Object {
            Write-Host "  • $($_.type): $($_.name)"
        }
        Write-Host "`nTotal resources: $($resources.Count)"
    }

    # Step 5: Confirmation
    if (-not $Force) {
        Write-Host ""
        Write-Warning "⚠️  WARNING: This action will DELETE all resources in the resource group!"
        Write-Host ""
        $confirmation = Read-Host "Type the resource group name to confirm deletion [$ResourceGroupName]"
        
        if ($confirmation -ne $ResourceGroupName) {
            Write-Warning "Deletion cancelled. Resource group name did not match."
            exit 0
        }
    } else {
        Write-Warning "Force flag set. Skipping confirmation prompt."
    }

    # Step 6: Delete resource group
    Write-Step "Deleting resource group and all resources..."
    Write-Warning "This may take several minutes..."
    Write-Host ""

    $deleteStartTime = Get-Date

    az group delete --name $ResourceGroupName --yes --no-wait --output none

    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Failed to initiate resource group deletion"
        exit 1
    }

    Write-Success "Resource group deletion initiated"
    Write-Host ""
    Write-ColorOutput "⏳ Deletion is running in the background..." -Color $ColorInfo
    Write-Host "   You can check status in the Azure Portal or run:"
    Write-Host "   az group show --name $ResourceGroupName"
    Write-Host ""

    # Optional: Wait for deletion to complete
    Write-Host "Waiting for deletion to complete (you can press Ctrl+C to exit without canceling the deletion)..."
    Write-Host ""

    $maxWaitMinutes = 15
    $waitInterval = 10
    $elapsedSeconds = 0

    while ($true) {
        Start-Sleep -Seconds $waitInterval
        $elapsedSeconds += $waitInterval

        $rgStillExists = az group exists --name $ResourceGroupName --output tsv 2>$null
        if ($rgStillExists -ne 'true') {
            break
        }

        $minutes = [Math]::Floor($elapsedSeconds / 60)
        $seconds = $elapsedSeconds % 60
        Write-Host "  Still deleting... (Elapsed: $($minutes)m $($seconds)s)" -NoNewline
        Write-Host "`r" -NoNewline

        if ($elapsedSeconds / 60 -ge $maxWaitMinutes) {
            Write-Host ""
            Write-Warning "Deletion is taking longer than expected. The operation is still running."
            Write-Host "Check the Azure Portal for status."
            break
        }
    }

    if ($rgStillExists -ne 'true') {
        $deleteEndTime = Get-Date
        $deleteDuration = $deleteEndTime - $deleteStartTime

        Write-Host ""
        Write-Success "Resource group deleted successfully!"
        Write-Host ""
        Write-ColorOutput "⏱️  Deletion Duration: $($deleteDuration.ToString('mm\:ss'))" -Color $ColorInfo
        Write-Host ""

        # Verify deletion
        Write-Step "Verifying deletion..."
        $verifyExists = az group exists --name $ResourceGroupName --output tsv 2>$null
        if ($verifyExists -eq 'true') {
            Write-Warning "Resource group still exists (possible Azure replication delay)"
        } else {
            Write-Success "Resource group confirmed deleted"
        }
    }

    # Step 7: Summary
    Write-ColorOutput @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║    ✅ Cleanup Complete!                                        ║
║                                                                ║
║    Resource group '$ResourceGroupName' has been deleted.      ║
║    All associated resources have been removed.                 ║
║                                                                ║
║    To redeploy:                                                ║
║    .\deploy.ps1 -ResourceGroupName "$ResourceGroupName" \    ║
║                 -Location "eastus"                             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@ -Color $ColorSuccess

} catch {
    Write-ErrorMessage "An unexpected error occurred:"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
    exit 1
}

#endregion

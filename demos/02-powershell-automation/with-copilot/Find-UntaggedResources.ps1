<#
.SYNOPSIS
    Finds Azure resources missing required tags.

.DESCRIPTION
    Scans Azure subscriptions or resource groups to identify resources that are missing
    required tags. Helps ensure tag compliance for governance, cost allocation, and
    resource management. Supports multiple output formats and tag validation rules.

.PARAMETER SubscriptionId
    Azure subscription ID to scan. If not specified, uses current subscription.

.PARAMETER ResourceGroupName
    Specific resource group to scan. If not specified, scans entire subscription.

.PARAMETER RequiredTags
    Array of tag names that are required on all resources.

.PARAMETER ExportPath
    Path to export results. Supports CSV, JSON, and HTML formats based on file extension.

.PARAMETER IncludeResourceTypes
    Filter to specific resource types (e.g., @('Microsoft.Compute/virtualMachines'))

.PARAMETER ExcludeResourceTypes
    Exclude specific resource types from the scan.

.EXAMPLE
    .\Find-UntaggedResources.ps1 -RequiredTags @('Environment', 'Owner', 'CostCenter')
    Scan current subscription for resources missing any of the three required tags.

.EXAMPLE
    .\Find-UntaggedResources.ps1 -ResourceGroupName 'rg-production' -RequiredTags @('Environment') -ExportPath 'untagged.csv'
    Scan specific resource group and export results to CSV.

.EXAMPLE
    .\Find-UntaggedResources.ps1 -RequiredTags @('Owner') -IncludeResourceTypes @('Microsoft.Compute/virtualMachines')
    Find only VMs that are missing the Owner tag.

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.Resources module
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string[]]$RequiredTags,

    [Parameter(Mandatory = $false)]
    [string]$ExportPath,

    [Parameter(Mandatory = $false)]
    [string[]]$IncludeResourceTypes,

    [Parameter(Mandatory = $false)]
    [string[]]$ExcludeResourceTypes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Get-MissingTags {
    param(
        [object]$Resource,
        [string[]]$RequiredTags
    )
    
    $resourceTags = @()
    if ($Resource.Tags) {
        $resourceTags = $Resource.Tags.Keys
    }
    
    $missingTags = $RequiredTags | Where-Object { $_ -notin $resourceTags }
    return $missingTags
}

function Export-Results {
    param(
        [array]$Results,
        [string]$Path
    )
    
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($extension) {
        '.csv' {
            $Results | Export-Csv -Path $Path -NoTypeInformation -Force
            Write-ColorOutput "✅ Results exported to CSV: $Path" -Color Green
        }
        '.json' {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Force
            Write-ColorOutput "✅ Results exported to JSON: $Path" -Color Green
        }
        '.html' {
            $html = $Results | ConvertTo-Html -Title "Untagged Resources Report" -PreContent "<h1>Untagged Resources Report</h1><p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>"
            $html | Out-File -FilePath $Path -Force
            Write-ColorOutput "✅ Results exported to HTML: $Path" -Color Green
        }
        default {
            Write-ColorOutput "⚠️  Unsupported export format. Using CSV." -Color Yellow
            $csvPath = [System.IO.Path]::ChangeExtension($Path, '.csv')
            $Results | Export-Csv -Path $csvPath -NoTypeInformation -Force
            Write-ColorOutput "✅ Results exported to CSV: $csvPath" -Color Green
        }
    }
}

#endregion

#region Main Script

try {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" -Color Cyan
    Write-ColorOutput "║          Find Untagged Azure Resources                    ║" -Color Cyan
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color Cyan
    
    # Set subscription context if specified
    if ($SubscriptionId) {
        Write-ColorOutput "`n🔄 Setting subscription context..." -Color Yellow
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        Write-ColorOutput "✅ Using subscription: $SubscriptionId" -Color Green
    }
    else {
        $context = Get-AzContext
        Write-ColorOutput "`n✅ Using current subscription: $($context.Subscription.Name)" -Color Green
    }
    
    # Get resources
    Write-ColorOutput "`n🔍 Scanning for resources..." -Color Yellow
    
    $getResourceParams = @{}
    if ($ResourceGroupName) {
        $getResourceParams['ResourceGroupName'] = $ResourceGroupName
        Write-ColorOutput "   Scope: Resource Group '$ResourceGroupName'" -Color Gray
    }
    else {
        Write-ColorOutput "   Scope: Entire Subscription" -Color Gray
    }
    
    $resources = Get-AzResource @getResourceParams
    Write-ColorOutput "✅ Found $($resources.Count) resources" -Color Green
    
    # Filter by resource type if specified
    if ($IncludeResourceTypes) {
        Write-ColorOutput "`n🔧 Filtering to include types: $($IncludeResourceTypes -join ', ')" -Color Yellow
        $resources = $resources | Where-Object { $_.ResourceType -in $IncludeResourceTypes }
        Write-ColorOutput "✅ Filtered to $($resources.Count) resources" -Color Green
    }
    
    if ($ExcludeResourceTypes) {
        Write-ColorOutput "`n🔧 Excluding types: $($ExcludeResourceTypes -join ', ')" -Color Yellow
        $resources = $resources | Where-Object { $_.ResourceType -notin $ExcludeResourceTypes }
        Write-ColorOutput "✅ Filtered to $($resources.Count) resources" -Color Green
    }
    
    # Check tags
    Write-ColorOutput "`n📋 Required tags: $($RequiredTags -join ', ')" -Color Cyan
    Write-ColorOutput "🔍 Checking tag compliance..." -Color Yellow
    
    $untaggedResources = @()
    $compliantCount = 0
    
    foreach ($resource in $resources) {
        $missingTags = Get-MissingTags -Resource $resource -RequiredTags $RequiredTags
        $missingTagsCount = ($missingTags | Measure-Object).Count
        
        if ($missingTagsCount -gt 0) {
            $existingTags = if ($resource.Tags) { ($resource.Tags.Keys -join ', ') } else { 'None' }
            
            $untaggedResources += [PSCustomObject]@{
                ResourceName = $resource.Name
                ResourceType = $resource.ResourceType
                ResourceGroup = $resource.ResourceGroupName
                Location = $resource.Location
                MissingTags = ($missingTags -join ', ')
                ExistingTags = $existingTags
                ResourceId = $resource.ResourceId
            }
        }
        else {
            $compliantCount++
        }
    }
    
    # Display results
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" -Color White
    Write-ColorOutput "║                    SCAN RESULTS                            ║" -Color White
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color White
    
    Write-ColorOutput "`n📊 Summary:" -Color White
    Write-ColorOutput "   Total Resources Scanned: $($resources.Count)" -Color Gray
    Write-ColorOutput "   ✅ Compliant: $compliantCount" -Color Green
    Write-ColorOutput "   ⚠️  Non-Compliant: $($untaggedResources.Count)" -Color $(if ($untaggedResources.Count -gt 0) { 'Yellow' } else { 'Green' })
    
    if ($untaggedResources.Count -gt 0) {
        $complianceRate = [Math]::Round(($compliantCount / $resources.Count) * 100, 1)
        Write-ColorOutput "`n   Compliance Rate: $complianceRate%" -Color $(if ($complianceRate -ge 90) { 'Green' } elseif ($complianceRate -ge 70) { 'Yellow' } else { 'Red' })
        
        Write-ColorOutput "`n⚠️  Resources with missing tags:" -Color Yellow
        
        # Group by resource type
        $groupedByType = $untaggedResources | Group-Object -Property ResourceType
        foreach ($group in $groupedByType | Sort-Object Count -Descending) {
            Write-ColorOutput "`n   $($group.Name) ($($group.Count))" -Color Cyan
            foreach ($resource in $group.Group | Select-Object -First 5) {
                Write-ColorOutput "      • $($resource.ResourceName) - Missing: $($resource.MissingTags)" -Color Gray
            }
            if ($group.Count -gt 5) {
                Write-ColorOutput "      ... and $($group.Count - 5) more" -Color DarkGray
            }
        }
        
        # Export results if path specified
        if ($ExportPath) {
            Write-ColorOutput "`n📤 Exporting results..." -Color Yellow
            Export-Results -Results $untaggedResources -Path $ExportPath
        }
    }
    else {
        Write-ColorOutput "`n✅ All resources are compliant!" -Color Green
    }
    
    Write-ColorOutput "`n✅ Scan completed successfully`n" -Color Green
}
catch {
    Write-ColorOutput "`n❌ Error: $($_.Exception.Message)" -Color Red
    Write-ColorOutput "   $($_.ScriptStackTrace)" -Color DarkGray
    exit 1
}

#endregion

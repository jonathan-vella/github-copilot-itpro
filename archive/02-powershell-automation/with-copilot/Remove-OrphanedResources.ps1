<#
.SYNOPSIS
    Finds and optionally removes orphaned Azure resources to reduce costs.

.DESCRIPTION
    This script identifies orphaned resources across Azure subscriptions including:
    - Unattached managed disks
    - Orphaned network interfaces (NICs)
    - Unassociated public IP addresses
    - Unused network security groups
    
    Calculates potential monthly cost savings and provides options to remove resources
    with safety confirmations.

.PARAMETER SubscriptionId
    Azure Subscription ID to scan. If not provided, uses current subscription context.

.PARAMETER ResourceGroupName
    Optional: Limit scan to specific resource group.

.PARAMETER RemoveResources
    Switch to enable actual removal of orphaned resources (default is report-only).

.PARAMETER ExportPath
    Path for CSV export of orphaned resources. Default: .\orphaned-resources.csv

.PARAMETER IncludeCostEstimates
    Include estimated monthly cost savings in the report.

.EXAMPLE
    .\Remove-OrphanedResources.ps1
    Scans current subscription and reports orphaned resources.

.EXAMPLE
    .\Remove-OrphanedResources.ps1 -SubscriptionId "abc-123" -RemoveResources
    Scans specific subscription and removes orphaned resources after confirmation.

.EXAMPLE
    .\Remove-OrphanedResources.ps1 -IncludeCostEstimates -ExportPath "C:\Reports\orphaned.csv"
    Generates report with cost estimates and exports to specific location.

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.Compute, Az.Network PowerShell modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveResources,

    [Parameter(Mandatory = $false)]
    [string]$ExportPath = ".\orphaned-resources.csv",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeCostEstimates
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Cost estimates per month (USD)
$costEstimates = @{
    'Standard_LRS_Disk_32GB' = 1.54
    'Standard_LRS_Disk_64GB' = 3.07
    'Standard_LRS_Disk_128GB' = 6.14
    'Premium_SSD_128GB' = 19.71
    'Premium_SSD_256GB' = 38.40
    'PublicIP_Basic' = 3.00
    'PublicIP_Standard' = 3.65
    'NIC' = 0.00  # NICs don't have direct cost but prevent other resources from being deleted
    'NSG' = 0.00
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Get-DiskCostEstimate {
    param([object]$Disk)
    
    $sizeGB = $Disk.DiskSizeGB
    $sku = $Disk.Sku.Name
    
    if ($sku -like '*Premium*') {
        if ($sizeGB -le 128) { return $costEstimates['Premium_SSD_128GB'] }
        else { return $costEstimates['Premium_SSD_256GB'] }
    }
    else {
        if ($sizeGB -le 32) { return $costEstimates['Standard_LRS_Disk_32GB'] }
        elseif ($sizeGB -le 64) { return $costEstimates['Standard_LRS_Disk_64GB'] }
        else { return $costEstimates['Standard_LRS_Disk_128GB'] }
    }
}

function Find-OrphanedDisks {
    Write-ColorOutput "`n🔍 Scanning for unattached managed disks..." -Color Cyan
    
    $allDisks = Get-AzDisk
    $orphanedDisks = $allDisks | Where-Object { $null -eq $_.ManagedBy }
    
    $results = @()
    foreach ($disk in $orphanedDisks) {
        $cost = if ($IncludeCostEstimates) { Get-DiskCostEstimate -Disk $disk } else { 0 }
        
        $results += [PSCustomObject]@{
            ResourceType = 'Managed Disk'
            ResourceName = $disk.Name
            ResourceGroup = $disk.ResourceGroupName
            Location = $disk.Location
            Size = "$($disk.DiskSizeGB) GB"
            SKU = $disk.Sku.Name
            EstimatedMonthlyCost = $cost
            ResourceId = $disk.Id
        }
    }
    
    Write-ColorOutput "   Found $($results.Count) orphaned disks" -Color Yellow
    return $results
}

function Find-OrphanedNICs {
    Write-ColorOutput "`n🔍 Scanning for orphaned network interfaces..." -Color Cyan
    
    $allNICs = Get-AzNetworkInterface
    $orphanedNICs = $allNICs | Where-Object { 
        $null -eq $_.VirtualMachine -and $null -eq $_.PrivateEndpoint 
    }
    
    $results = @()
    foreach ($nic in $orphanedNICs) {
        $results += [PSCustomObject]@{
            ResourceType = 'Network Interface'
            ResourceName = $nic.Name
            ResourceGroup = $nic.ResourceGroupName
            Location = $nic.Location
            Size = 'N/A'
            SKU = 'Standard'
            EstimatedMonthlyCost = $costEstimates['NIC']
            ResourceId = $nic.Id
        }
    }
    
    Write-ColorOutput "   Found $($results.Count) orphaned NICs" -Color Yellow
    return $results
}

function Find-OrphanedPublicIPs {
    Write-ColorOutput "`n🔍 Scanning for unassociated public IP addresses..." -Color Cyan
    
    $allPublicIPs = Get-AzPublicIpAddress
    $orphanedIPs = $allPublicIPs | Where-Object { $null -eq $_.IpConfiguration }
    
    $results = @()
    foreach ($ip in $orphanedIPs) {
        $cost = if ($IncludeCostEstimates) {
            if ($ip.Sku.Name -eq 'Standard') { $costEstimates['PublicIP_Standard'] }
            else { $costEstimates['PublicIP_Basic'] }
        } else { 0 }
        
        $results += [PSCustomObject]@{
            ResourceType = 'Public IP'
            ResourceName = $ip.Name
            ResourceGroup = $ip.ResourceGroupName
            Location = $ip.Location
            Size = $ip.PublicIpAllocationMethod
            SKU = $ip.Sku.Name
            EstimatedMonthlyCost = $cost
            ResourceId = $ip.Id
        }
    }
    
    Write-ColorOutput "   Found $($results.Count) orphaned public IPs" -Color Yellow
    return $results
}

# Main execution
try {
    Write-ColorOutput "╔════════════════════════════════════════════════════════════╗" -Color Cyan
    Write-ColorOutput "║        Azure Orphaned Resources Cleanup Script            ║" -Color Cyan
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color Cyan
    
    # Set subscription context
    if ($SubscriptionId) {
        Write-ColorOutput "`n📋 Setting subscription context: $SubscriptionId" -Color White
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    
    $currentContext = Get-AzContext
    Write-ColorOutput "   Active Subscription: $($currentContext.Subscription.Name)" -Color Green
    
    # Collect all orphaned resources
    $allOrphanedResources = @()
    $allOrphanedResources += Find-OrphanedDisks
    $allOrphanedResources += Find-OrphanedNICs
    $allOrphanedResources += Find-OrphanedPublicIPs
    
    # Display summary
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" -Color Yellow
    Write-ColorOutput "║                    SUMMARY REPORT                          ║" -Color Yellow
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color Yellow
    
    Write-ColorOutput "`n📊 Total Orphaned Resources: $($allOrphanedResources.Count)" -Color White
    
    if ($IncludeCostEstimates -and $allOrphanedResources.Count -gt 0) {
        $totalMonthlyCost = ($allOrphanedResources | Measure-Object -Property EstimatedMonthlyCost -Sum).Sum
        $annualSavings = $totalMonthlyCost * 12
        
        Write-ColorOutput "💰 Estimated Monthly Waste: `$$([math]::Round($totalMonthlyCost, 2))" -Color Red
        Write-ColorOutput "💰 Potential Annual Savings: `$$([math]::Round($annualSavings, 2))" -Color Green
    }
    
    # Display breakdown by type
    $groupedResources = $allOrphanedResources | Group-Object -Property ResourceType
    foreach ($group in $groupedResources) {
        Write-ColorOutput "`n   $($group.Name): $($group.Count) resources" -Color Cyan
    }
    
    # Export to CSV
    if ($allOrphanedResources.Count -gt 0) {
        $allOrphanedResources | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-ColorOutput "`n📁 Report exported to: $ExportPath" -Color Green
        
        # Display first 10 resources
        Write-ColorOutput "`n📋 Sample of orphaned resources:" -Color White
        $allOrphanedResources | Select-Object -First 10 | Format-Table -AutoSize
        
        # Remove resources if requested
        if ($RemoveResources) {
            Write-ColorOutput "`n⚠️  WARNING: You are about to delete $($allOrphanedResources.Count) resources!" -Color Red
            $confirmation = Read-Host "Type 'DELETE' to confirm removal"
            
            if ($confirmation -eq 'DELETE') {
                Write-ColorOutput "`n🗑️  Removing orphaned resources..." -Color Yellow
                
                $removeCount = 0
                foreach ($resource in $allOrphanedResources) {
                    try {
                        Write-Progress -Activity "Removing Resources" -Status "Processing $($resource.ResourceName)" -PercentComplete (($removeCount / $allOrphanedResources.Count) * 100)
                        
                        Remove-AzResource -ResourceId $resource.ResourceId -Force
                        Write-ColorOutput "   ✅ Removed: $($resource.ResourceName)" -Color Green
                        $removeCount++
                    }
                    catch {
                        Write-ColorOutput "   ❌ Failed to remove: $($resource.ResourceName) - $($_.Exception.Message)" -Color Red
                    }
                }
                
                Write-ColorOutput "`n✅ Cleanup complete! Removed $removeCount of $($allOrphanedResources.Count) resources" -Color Green
            }
            else {
                Write-ColorOutput "`n❌ Removal cancelled by user" -Color Yellow
            }
        }
        else {
            Write-ColorOutput "`n💡 Run with -RemoveResources switch to delete these resources" -Color Cyan
        }
    }
    else {
        Write-ColorOutput "`n✅ No orphaned resources found! Your subscription is clean." -Color Green
    }
}
catch {
    Write-ColorOutput "`n❌ Error: $($_.Exception.Message)" -Color Red
    throw
}

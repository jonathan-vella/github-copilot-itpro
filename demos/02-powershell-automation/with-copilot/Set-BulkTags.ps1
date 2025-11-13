<#
.SYNOPSIS
    Applies tags to multiple Azure resources in bulk with parallel processing.

.DESCRIPTION
    This script enables efficient bulk tagging operations across Azure subscriptions.
    Features include:
    - Tag multiple resources simultaneously with parallel processing
    - Merge or replace existing tags
    - Dry-run mode for validation before applying changes
    - Progress tracking and detailed logging
    - Filter by resource group, type, or tag criteria

.PARAMETER SubscriptionId
    Azure Subscription ID to target. If not provided, uses current subscription context.

.PARAMETER ResourceGroupName
    Optional: Apply tags only to resources in specific resource group.

.PARAMETER Tags
    Hashtable of tags to apply. Example: @{Environment='Production'; Owner='TeamA'}

.PARAMETER ResourceType
    Optional: Filter by specific resource type (e.g., 'Microsoft.Compute/virtualMachines')

.PARAMETER MergeMode
    If specified, merges new tags with existing tags. Otherwise replaces all tags.

.PARAMETER DryRun
    Preview changes without applying them.

.PARAMETER MaxParallelJobs
    Maximum number of parallel tagging operations. Default: 10

.PARAMETER FilterTag
    Optional: Only tag resources that already have this tag. Example: @{Environment='Dev'}

.EXAMPLE
    .\Set-BulkTags.ps1 -Tags @{Environment='Production'; CostCenter='IT-Ops'}
    Applies tags to all resources in current subscription.

.EXAMPLE
    .\Set-BulkTags.ps1 -ResourceGroupName "rg-prod" -Tags @{Owner='TeamA'} -MergeMode
    Merges Owner tag with existing tags for all resources in specific resource group.

.EXAMPLE
    .\Set-BulkTags.ps1 -DryRun -Tags @{Project='Migration'} -ResourceType 'Microsoft.Storage/storageAccounts'
    Preview tagging all storage accounts without applying changes.

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.Resources PowerShell module
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [hashtable]$Tags,

    [Parameter(Mandatory = $false)]
    [string]$ResourceType,

    [Parameter(Mandatory = $false)]
    [switch]$MergeMode,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 50)]
    [int]$MaxParallelJobs = 10,

    [Parameter(Mandatory = $false)]
    [hashtable]$FilterTag
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Get-TargetResources {
    Write-ColorOutput "`n🔍 Discovering target resources..." -Color Cyan
    
    $filterParams = @{}
    if ($ResourceGroupName) {
        $filterParams['ResourceGroupName'] = $ResourceGroupName
    }
    if ($ResourceType) {
        $filterParams['ResourceType'] = $ResourceType
    }
    
    $resources = Get-AzResource @filterParams
    
    # Apply tag filter if specified
    if ($FilterTag) {
        $tagKey = $FilterTag.Keys | Select-Object -First 1
        $tagValue = $FilterTag[$tagKey]
        $resources = $resources | Where-Object { 
            $_.Tags -and $_.Tags.ContainsKey($tagKey) -and $_.Tags[$tagKey] -eq $tagValue 
        }
    }
    
    Write-ColorOutput "   Found $($resources.Count) resources matching criteria" -Color Green
    return $resources
}

function New-MergedTags {
    param(
        [object]$Resource,
        [hashtable]$NewTags
    )
    
    $mergedTags = @{}
    
    # Copy existing tags if in merge mode
    if ($MergeMode -and $Resource.Tags) {
        foreach ($key in $Resource.Tags.Keys) {
            $mergedTags[$key] = $Resource.Tags[$key]
        }
    }
    
    # Add/override with new tags
    foreach ($key in $NewTags.Keys) {
        $mergedTags[$key] = $NewTags[$key]
    }
    
    return $mergedTags
}

function Show-TaggingPreview {
    param([array]$Resources)
    
    Write-ColorOutput "`n📋 TAGGING PREVIEW" -Color Yellow
    Write-ColorOutput "════════════════════════════════════════════════════════════" -Color Yellow
    
    Write-ColorOutput "`n📊 Summary:" -Color White
    Write-ColorOutput "   Resources to tag: $($Resources.Count)" -Color Cyan
    Write-ColorOutput "   Tagging mode: $(if ($MergeMode) { 'MERGE with existing tags' } else { 'REPLACE all tags' })" -Color Cyan
    Write-ColorOutput "   New tags to apply:" -Color Cyan
    foreach ($key in $Tags.Keys) {
        Write-ColorOutput "      $key = $($Tags[$key])" -Color White
    }
    
    Write-ColorOutput "`n📝 Sample of resources (first 10):" -Color White
    $Resources | Select-Object -First 10 | ForEach-Object {
        Write-ColorOutput "`n   Resource: $($_.Name)" -Color Cyan
        Write-ColorOutput "   Type: $($_.ResourceType)" -Color White
        Write-ColorOutput "   Resource Group: $($_.ResourceGroupName)" -Color White
        
        if ($_.Tags) {
            Write-ColorOutput "   Current Tags:" -Color Yellow
            foreach ($key in $_.Tags.Keys) {
                Write-ColorOutput "      $key = $($_.Tags[$key])" -Color White
            }
        }
        else {
            Write-ColorOutput "   Current Tags: None" -Color Yellow
        }
        
        $mergedTags = New-MergedTags -Resource $_ -NewTags $Tags
        Write-ColorOutput "   After Tagging:" -Color Green
        foreach ($key in $mergedTags.Keys) {
            Write-ColorOutput "      $key = $($mergedTags[$key])" -Color White
        }
    }
}

function Update-ResourceTags {
    param([array]$Resources)
    
    Write-ColorOutput "`n🏷️  Applying tags..." -Color Cyan
    
    $jobs = @()
    $completed = 0
    $failed = 0
    $batchSize = $MaxParallelJobs
    
    for ($i = 0; $i -lt $Resources.Count; $i += $batchSize) {
        $batch = $Resources[$i..[Math]::Min($i + $batchSize - 1, $Resources.Count - 1)]
        
        foreach ($resource in $batch) {
            $job = Start-Job -ScriptBlock {
                param($ResourceId, $NewTags, $MergeMode)
                
                try {
                    $resource = Get-AzResource -ResourceId $ResourceId
                    
                    if ($MergeMode -and $resource.Tags) {
                        $mergedTags = @{}
                        foreach ($key in $resource.Tags.Keys) {
                            $mergedTags[$key] = $resource.Tags[$key]
                        }
                        foreach ($key in $NewTags.Keys) {
                            $mergedTags[$key] = $NewTags[$key]
                        }
                        $finalTags = $mergedTags
                    }
                    else {
                        $finalTags = $NewTags
                    }
                    
                    Set-AzResource -ResourceId $ResourceId -Tag $finalTags -Force | Out-Null
                    
                    return @{
                        Success = $true
                        ResourceName = $resource.Name
                        Message = "Tagged successfully"
                    }
                }
                catch {
                    return @{
                        Success = $false
                        ResourceName = $resource.Name
                        Message = $_.Exception.Message
                    }
                }
            } -ArgumentList $resource.ResourceId, $Tags, $MergeMode
            
            $jobs += $job
        }
        
        # Wait for batch to complete
        $jobs | Wait-Job | Out-Null
        
        foreach ($job in $jobs) {
            $result = Receive-Job -Job $job
            
            if ($result.Success) {
                Write-ColorOutput "   ✅ $($result.ResourceName)" -Color Green
                $completed++
            }
            else {
                Write-ColorOutput "   ❌ $($result.ResourceName) - $($result.Message)" -Color Red
                $failed++
            }
            
            Remove-Job -Job $job
        }
        
        $jobs = @()
        
        # Update progress
        $percentComplete = [Math]::Min(100, [int](($i + $batchSize) / $Resources.Count * 100))
        Write-Progress -Activity "Applying Tags" -Status "$completed/$($Resources.Count) completed" -PercentComplete $percentComplete
    }
    
    Write-Progress -Activity "Applying Tags" -Completed
    
    return @{
        Total = $Resources.Count
        Completed = $completed
        Failed = $failed
    }
}

# Main execution
try {
    Write-ColorOutput "╔════════════════════════════════════════════════════════════╗" -Color Cyan
    Write-ColorOutput "║          Azure Bulk Tagging Script                         ║" -Color Cyan
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color Cyan
    
    # Set subscription context
    if ($SubscriptionId) {
        Write-ColorOutput "`n📋 Setting subscription context: $SubscriptionId" -Color White
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    
    $currentContext = Get-AzContext
    Write-ColorOutput "   Active Subscription: $($currentContext.Subscription.Name)" -Color Green
    
    # Get target resources
    $targetResources = Get-TargetResources
    
    if ($targetResources.Count -eq 0) {
        Write-ColorOutput "`n⚠️  No resources found matching the criteria" -Color Yellow
        exit 0
    }
    
    # Show preview
    Show-TaggingPreview -Resources $targetResources
    
    if ($DryRun) {
        Write-ColorOutput "`n💡 DRY RUN MODE - No changes applied" -Color Cyan
        Write-ColorOutput "   Remove -DryRun parameter to apply tags" -Color White
        exit 0
    }
    
    # Confirm before proceeding
    Write-ColorOutput "`n⚠️  Ready to tag $($targetResources.Count) resources" -Color Yellow
    $confirmation = Read-Host "Type 'APPLY' to proceed"
    
    if ($confirmation -ne 'APPLY') {
        Write-ColorOutput "`n❌ Operation cancelled by user" -Color Red
        exit 0
    }
    
    # Apply tags
    $results = Update-ResourceTags -Resources $targetResources
    
    # Display summary
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" -Color Green
    Write-ColorOutput "║                  TAGGING COMPLETE                          ║" -Color Green
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" -Color Green
    
    Write-ColorOutput "`n📊 Results:" -Color White
    Write-ColorOutput "   ✅ Successfully tagged: $($results.Completed)" -Color Green
    Write-ColorOutput "   ❌ Failed: $($results.Failed)" -Color Red
    Write-ColorOutput "   📊 Total processed: $($results.Total)" -Color Cyan
    
    $successRate = [Math]::Round(($results.Completed / $results.Total) * 100, 1)
    Write-ColorOutput "`n   Success Rate: $successRate%" -Color $(if ($successRate -ge 95) { 'Green' } else { 'Yellow' })
}
catch {
    Write-ColorOutput "`n❌ Error: $($_.Exception.Message)" -Color Red
    throw
}

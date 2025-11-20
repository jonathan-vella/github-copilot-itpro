<#
.SYNOPSIS
    Generates comprehensive Azure resource inventory and cost reports across subscriptions.

.DESCRIPTION
    This script provides detailed insights into Azure resources with features including:
    - Resource inventory across single or multiple subscriptions
    - Cost analysis with breakdown by resource group and type
    - Tag compliance checking
    - Orphaned resource detection (unattached disks, unused IPs, empty NICs)
    - Export to multiple formats (CSV, JSON, HTML)
    - Detailed logging and progress tracking

.PARAMETER SubscriptionId
    Azure Subscription ID to analyze. If not provided, uses current subscription context.
    Can also accept array of subscription IDs for multi-subscription reporting.

.PARAMETER ResourceGroupName
    Optional: Analyze only resources in specific resource group.

.PARAMETER IncludeCost
    Include cost data in the report (requires Cost Management Reader role).
    Cost data covers the last 30 days.

.PARAMETER CheckOrphaned
    Scan for orphaned resources (unattached disks, unused public IPs, disconnected NICs).

.PARAMETER OutputPath
    Directory path for report files. Default: Current directory.

.PARAMETER OutputFormat
    Report format: CSV, JSON, HTML, or All. Default: CSV.

.PARAMETER CheckTagCompliance
    Check for resources missing required tags.

.PARAMETER RequiredTags
    Array of tag names that resources should have. Example: @('Environment','Owner','CostCenter')

.EXAMPLE
    .\Get-AzResourceReport.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"
    Generate basic resource inventory for specified subscription.

.EXAMPLE
    .\Get-AzResourceReport.ps1 -IncludeCost -CheckOrphaned -OutputFormat All
    Generate comprehensive report with cost data and orphaned resources in all formats.

.EXAMPLE
    .\Get-AzResourceReport.ps1 -CheckTagCompliance -RequiredTags @('Environment','Owner') -OutputFormat HTML
    Check tag compliance and generate HTML report.

.EXAMPLE
    .\Get-AzResourceReport.ps1 -SubscriptionId @("sub-id-1","sub-id-2") -IncludeCost -OutputPath "C:\Reports"
    Generate cost report for multiple subscriptions.

.NOTES
    Author: IT Operations Team
    Requires: Az.Accounts, Az.Resources, Az.CostManagement modules
    Permissions: Reader role minimum, Cost Management Reader for cost data
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string[]]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeCost,

    [Parameter(Mandatory = $false)]
    [switch]$CheckOrphaned,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('CSV', 'JSON', 'HTML', 'All')]
    [string]$OutputFormat = 'CSV',

    [Parameter(Mandatory = $false)]
    [switch]$CheckTagCompliance,

    [Parameter(Mandatory = $false)]
    [string[]]$RequiredTags = @('Environment', 'Owner', 'CostCenter')
)

# Script initialization
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Color output functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    $colorMap = @{
        'Green'  = [ConsoleColor]::Green
        'Yellow' = [ConsoleColor]::Yellow
        'Red'    = [ConsoleColor]::Red
        'Cyan'   = [ConsoleColor]::Cyan
        'Gray'   = [ConsoleColor]::Gray
    }
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Write-Success { param([string]$Message) Write-ColorOutput "✅ $Message" -Color Green }
function Write-Warning { param([string]$Message) Write-ColorOutput "⚠️  $Message" -Color Yellow }
function Write-ErrorMessage { param([string]$Message) Write-ColorOutput "❌ $Message" -Color Red }
function Write-Info { param([string]$Message) Write-ColorOutput "ℹ️  $Message" -Color Cyan }

# Initialize logging
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
# Determine if OutputPath is a directory or file path
$outputDir = if (Test-Path $OutputPath -PathType Container) {
    $OutputPath
} elseif (Test-Path $OutputPath -PathType Leaf) {
    Split-Path $OutputPath -Parent
} else {
    # Path doesn't exist yet - check if it has an extension (file) or not (directory)
    if ([System.IO.Path]::HasExtension($OutputPath)) {
        $parent = Split-Path $OutputPath -Parent
        if ($parent) { $parent } else { (Get-Location).Path }
    } else {
        $OutputPath
    }
}
$logFile = Join-Path $outputDir "ResourceReport_$timestamp.log"

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $logEntry = "{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Add-Content -Path $logFile -Value $logEntry
    
    switch ($Level) {
        'ERROR' { Write-ErrorMessage $Message }
        'WARNING' { Write-Warning $Message }
        'SUCCESS' { Write-Success $Message }
        'INFO' { Write-Info $Message }
        default { Write-Host $Message }
    }
}

# Banner
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║  Azure Resource Report Generator                         ║" -Color Cyan
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" -Color Cyan
Write-Host ""

Write-Log "Script started" -Level INFO
Write-Log "Output path: $OutputPath" -Level INFO
Write-Log "Output format: $OutputFormat" -Level INFO

# Check prerequisites
Write-Log "Checking prerequisites..." -Level INFO

try {
    $azModules = @('Az.Accounts', 'Az.Resources')
    if ($IncludeCost) { $azModules += 'Az.CostManagement' }
    
    foreach ($module in $azModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Log "Required module $module is not installed. Install with: Install-Module -Name $module" -Level ERROR
            exit 1
        }
    }
    Write-Success "All required modules are installed"
}
catch {
    Write-Log "Error checking modules: $_" -Level ERROR
    exit 1
}

# Connect to Azure
Write-Log "Checking Azure connection..." -Level INFO

try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Log "Not connected to Azure. Connecting..." -Level WARNING
        Connect-AzAccount
        $context = Get-AzContext
    }
    
    Write-Success "Connected to Azure"
    Write-Host "  Account: $($context.Account.Id)" -ForegroundColor Gray
    Write-Host "  Tenant: $($context.Tenant.Id)" -ForegroundColor Gray
    
    # Get subscriptions to process
    if ($SubscriptionId) {
        $subscriptions = $SubscriptionId | ForEach-Object {
            Set-AzContext -SubscriptionId $_ -ErrorAction Stop
            Get-AzSubscription -SubscriptionId $_
        }
    }
    else {
        $subscriptions = @(Get-AzSubscription -SubscriptionId $context.Subscription.Id)
    }
    
    Write-Log "Processing $($subscriptions.Count) subscription(s)" -Level INFO
}
catch {
    Write-Log "Failed to connect to Azure: $_" -Level ERROR
    exit 1
}

# Initialize results collection
$allResources = @()
$costData = @()
$orphanedResources = @()
$tagComplianceIssues = @()

# Process each subscription
foreach ($sub in $subscriptions) {
    Write-Host ""
    Write-Log "Processing subscription: $($sub.Name) ($($sub.Id))" -Level INFO
    
    try {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        
        # Get resources
        Write-Log "Retrieving resources..." -Level INFO
        
        $getResourceParams = @{}
        if ($ResourceGroupName) {
            $getResourceParams['ResourceGroupName'] = $ResourceGroupName
        }
        
        $resources = Get-AzResource @getResourceParams
        Write-Success "Found $($resources.Count) resources"
        
        # Process each resource
        $counter = 0
        foreach ($resource in $resources) {
            $counter++
            $percentComplete = [math]::Round(($counter / $resources.Count) * 100, 0)
            Write-Progress -Activity "Processing resources" -Status "$counter of $($resources.Count)" -PercentComplete $percentComplete
            
            # Build resource object
            $resourceObj = [PSCustomObject]@{
                SubscriptionName = $sub.Name
                SubscriptionId   = $sub.Id
                ResourceName     = $resource.Name
                ResourceType     = $resource.ResourceType
                ResourceGroup    = $resource.ResourceGroupName
                Location         = $resource.Location
                Tags             = ($resource.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; '
                ResourceId       = $resource.ResourceId
            }
            
            # Check tag compliance if requested
            if ($CheckTagCompliance) {
                $missingTags = $RequiredTags | Where-Object { -not $resource.Tags.ContainsKey($_) }
                if ($missingTags) {
                    $tagComplianceIssues += [PSCustomObject]@{
                        SubscriptionName = $sub.Name
                        ResourceName     = $resource.Name
                        ResourceType     = $resource.ResourceType
                        ResourceGroup    = $resource.ResourceGroupName
                        MissingTags      = $missingTags -join ', '
                    }
                }
            }
            
            $allResources += $resourceObj
        }
        
        Write-Progress -Activity "Processing resources" -Completed
        
        # Check for orphaned resources if requested
        if ($CheckOrphaned) {
            Write-Log "Checking for orphaned resources..." -Level INFO
            
            # Unattached disks
            $disks = Get-AzDisk -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
            $unattachedDisks = $disks | Where-Object { -not $_.ManagedBy }
            
            foreach ($disk in $unattachedDisks) {
                $orphanedResources += [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceName     = $disk.Name
                    ResourceType     = 'Unattached Disk'
                    ResourceGroup    = $disk.ResourceGroupName
                    Location         = $disk.Location
                    Size             = "$($disk.DiskSizeGB) GB"
                    EstimatedMonthlyCost = "$([math]::Round($disk.DiskSizeGB * 0.05, 2))"
                }
            }
            
            # Unused public IPs
            $publicIps = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
            $unusedIps = $publicIps | Where-Object { -not $_.IpConfiguration }
            
            foreach ($ip in $unusedIps) {
                $orphanedResources += [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceName     = $ip.Name
                    ResourceType     = 'Unused Public IP'
                    ResourceGroup    = $ip.ResourceGroupName
                    Location         = $ip.Location
                    IPAddress        = $ip.IpAddress
                    EstimatedMonthlyCost = "~$3-5"
                }
            }
            
            # Disconnected NICs
            $nics = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
            $disconnectedNics = $nics | Where-Object { -not $_.VirtualMachine }
            
            foreach ($nic in $disconnectedNics) {
                $orphanedResources += [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceName     = $nic.Name
                    ResourceType     = 'Disconnected NIC'
                    ResourceGroup    = $nic.ResourceGroupName
                    Location         = $nic.Location
                    EstimatedMonthlyCost = "Minimal"
                }
            }
            
            Write-Success "Found $($orphanedResources.Count) orphaned resources"
        }
        
        # Get cost data if requested
        if ($IncludeCost) {
            Write-Log "Retrieving cost data (last 30 days)..." -Level INFO
            
            try {
                $startDate = (Get-Date).AddDays(-30).ToString('yyyy-MM-dd')
                $endDate = (Get-Date).ToString('yyyy-MM-dd')
                
                $usage = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate -ErrorAction SilentlyContinue
                
                if ($usage) {
                    $costSummary = $usage | Group-Object -Property InstanceName | ForEach-Object {
                        [PSCustomObject]@{
                            SubscriptionName = $sub.Name
                            ResourceName     = $_.Name
                            TotalCost        = ($_.Group | Measure-Object -Property PretaxCost -Sum).Sum
                            Currency         = $_.Group[0].Currency
                        }
                    }
                    
                    $costData += $costSummary
                    Write-Success "Retrieved cost data for $($costSummary.Count) resources"
                }
                else {
                    Write-Warning "No cost data available for this subscription"
                }
            }
            catch {
                Write-Log "Error retrieving cost data: $_" -Level WARNING
            }
        }
    }
    catch {
        Write-Log "Error processing subscription $($sub.Name): $_" -Level ERROR
    }
}

# Generate reports
Write-Host ""
Write-Log "Generating reports..." -Level INFO

$reportFiles = @()

# CSV Export
if ($OutputFormat -in @('CSV', 'All')) {
    try {
        # If OutputPath has a .csv extension, use it directly; otherwise generate filename
        if ([System.IO.Path]::GetExtension($OutputPath) -eq '.csv') {
            $csvFile = $OutputPath
        } else {
            $csvFile = Join-Path $outputDir "ResourceInventory_$timestamp.csv"
        }
        $allResources | Export-Csv -Path $csvFile -NoTypeInformation
        $reportFiles += $csvFile
        Write-Success "CSV report saved: $csvFile"
        
        if ($CheckOrphaned -and $orphanedResources.Count -gt 0) {
            $orphanedCsv = Join-Path $outputDir "OrphanedResources_$timestamp.csv"
            $orphanedResources | Export-Csv -Path $orphanedCsv -NoTypeInformation
            $reportFiles += $orphanedCsv
            Write-Success "Orphaned resources CSV saved: $orphanedCsv"
        }
        
        if ($CheckTagCompliance -and $tagComplianceIssues.Count -gt 0) {
            $complianceCsv = Join-Path $outputDir "TagCompliance_$timestamp.csv"
            $tagComplianceIssues | Export-Csv -Path $complianceCsv -NoTypeInformation
            $reportFiles += $complianceCsv
            Write-Success "Tag compliance CSV saved: $complianceCsv"
        }
        
        if ($IncludeCost -and $costData.Count -gt 0) {
            $costCsv = Join-Path $outputDir "ResourceCosts_$timestamp.csv"
            $costData | Export-Csv -Path $costCsv -NoTypeInformation
            $reportFiles += $costCsv
            Write-Success "Cost data CSV saved: $costCsv"
        }
    }
    catch {
        Write-Log "Error generating CSV report: $_" -Level ERROR
    }
}

# JSON Export
if ($OutputFormat -in @('JSON', 'All')) {
    try {
        $jsonFile = Join-Path $outputDir "ResourceInventory_$timestamp.json"
        $reportData = @{
            GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Subscriptions = $subscriptions.Count
            TotalResources = $allResources.Count
            Resources = $allResources
        }
        
        if ($CheckOrphaned) { $reportData['OrphanedResources'] = $orphanedResources }
        if ($CheckTagCompliance) { $reportData['TagComplianceIssues'] = $tagComplianceIssues }
        if ($IncludeCost) { $reportData['CostData'] = $costData }
        
        $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonFile
        $reportFiles += $jsonFile
        Write-Success "JSON report saved: $jsonFile"
    }
    catch {
        Write-Log "Error generating JSON report: $_" -Level ERROR
    }
}

# HTML Export
if ($OutputFormat -in @('HTML', 'All')) {
    try {
        $htmlFile = Join-Path $outputDir "ResourceInventory_$timestamp.html"
        
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Resource Report - $timestamp</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078d4; }
        h2 { color: #005a9e; margin-top: 30px; }
        .summary { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .summary-item { display: inline-block; margin: 10px 20px 10px 0; }
        .summary-label { font-weight: bold; color: #666; }
        .summary-value { font-size: 24px; color: #0078d4; }
        table { border-collapse: collapse; width: 100%; background: white; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background-color: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f5f5f5; }
        .warning { color: #ff8c00; font-weight: bold; }
        .error { color: #d32f2f; font-weight: bold; }
        .footer { margin-top: 40px; padding: 20px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <h1>🔷 Azure Resource Inventory Report</h1>
    <div class="summary">
        <div class="summary-item">
            <div class="summary-label">Generated</div>
            <div class="summary-value">$(Get-Date -Format 'yyyy-MM-dd HH:mm')</div>
        </div>
        <div class="summary-item">
            <div class="summary-label">Subscriptions</div>
            <div class="summary-value">$($subscriptions.Count)</div>
        </div>
        <div class="summary-item">
            <div class="summary-label">Total Resources</div>
            <div class="summary-value">$($allResources.Count)</div>
        </div>
"@

        if ($CheckOrphaned) {
            $html += @"
        <div class="summary-item">
            <div class="summary-label">Orphaned Resources</div>
            <div class="summary-value" style="color: #ff8c00;">$($orphanedResources.Count)</div>
        </div>
"@
        }

        if ($CheckTagCompliance) {
            $html += @"
        <div class="summary-item">
            <div class="summary-label">Tag Compliance Issues</div>
            <div class="summary-value" style="color: #d32f2f;">$($tagComplianceIssues.Count)</div>
        </div>
"@
        }

        $html += @"
    </div>
    
    <h2>📊 Resource Inventory</h2>
    <table>
        <tr>
            <th>Subscription</th>
            <th>Resource Name</th>
            <th>Type</th>
            <th>Resource Group</th>
            <th>Location</th>
            <th>Tags</th>
        </tr>
"@

        foreach ($resource in $allResources) {
            $html += @"
        <tr>
            <td>$($resource.SubscriptionName)</td>
            <td>$($resource.ResourceName)</td>
            <td>$($resource.ResourceType)</td>
            <td>$($resource.ResourceGroup)</td>
            <td>$($resource.Location)</td>
            <td>$($resource.Tags)</td>
        </tr>
"@
        }

        $html += "</table>"

        if ($CheckOrphaned -and $orphanedResources.Count -gt 0) {
            $html += @"
    <h2>⚠️  Orphaned Resources</h2>
    <table>
        <tr>
            <th>Resource Name</th>
            <th>Type</th>
            <th>Resource Group</th>
            <th>Location</th>
            <th>Est. Monthly Cost</th>
        </tr>
"@
            foreach ($orphaned in $orphanedResources) {
                $html += @"
        <tr>
            <td class="warning">$($orphaned.ResourceName)</td>
            <td>$($orphaned.ResourceType)</td>
            <td>$($orphaned.ResourceGroup)</td>
            <td>$($orphaned.Location)</td>
            <td>$($orphaned.EstimatedMonthlyCost)</td>
        </tr>
"@
            }
            $html += "</table>"
        }

        if ($CheckTagCompliance -and $tagComplianceIssues.Count -gt 0) {
            $html += @"
    <h2>🏷️  Tag Compliance Issues</h2>
    <table>
        <tr>
            <th>Resource Name</th>
            <th>Type</th>
            <th>Resource Group</th>
            <th>Missing Tags</th>
        </tr>
"@
            foreach ($issue in $tagComplianceIssues) {
                $html += @"
        <tr>
            <td class="error">$($issue.ResourceName)</td>
            <td>$($issue.ResourceType)</td>
            <td>$($issue.ResourceGroup)</td>
            <td>$($issue.MissingTags)</td>
        </tr>
"@
            }
            $html += "</table>"
        }

        $html += @"
    <div class="footer">
        Generated by Azure Resource Report Generator | $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    </div>
</body>
</html>
"@

        $html | Out-File -FilePath $htmlFile -Encoding UTF8
        $reportFiles += $htmlFile
        Write-Success "HTML report saved: $htmlFile"
    }
    catch {
        Write-Log "Error generating HTML report: $_" -Level ERROR
    }
}

# Summary
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║  Report Summary                                           ║" -Color Cyan
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" -Color Cyan
Write-Host ""

Write-Success "Total subscriptions processed: $($subscriptions.Count)"
Write-Success "Total resources found: $($allResources.Count)"

if ($CheckOrphaned) {
    if ($orphanedResources.Count -gt 0) {
        Write-Warning "Orphaned resources found: $($orphanedResources.Count)"
    } else {
        Write-Success "No orphaned resources found"
    }
}

if ($CheckTagCompliance) {
    if ($tagComplianceIssues.Count -gt 0) {
        Write-Warning "Resources with tag compliance issues: $($tagComplianceIssues.Count)"
    } else {
        Write-Success "All resources comply with tagging requirements"
    }
}

Write-Host ""
Write-Info "Report files generated:"
foreach ($file in $reportFiles) {
    Write-Host "  📄 $file" -ForegroundColor Gray
}

Write-Host ""
Write-Log "Script completed successfully" -Level SUCCESS
Write-Host ""

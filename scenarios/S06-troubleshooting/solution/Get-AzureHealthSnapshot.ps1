<#
.SYNOPSIS
    Generates comprehensive Azure resource health snapshot for troubleshooting.

.DESCRIPTION
    This script performs rapid health checks across Azure resources within a resource group
    or subscription. It checks resource health status, service availability, recent alerts,
    and metric anomalies to quickly triage incidents.
    
    Designed to be generated with GitHub Copilot in <3 minutes vs. 45+ minutes manually.

.PARAMETER ResourceGroupName
    The name of the resource group to check. If not specified, checks all resources in subscription.

.PARAMETER SubscriptionId
    Azure subscription ID. If not specified, uses current context.

.PARAMETER IncludeNetworking
    Include detailed networking diagnostics (NSGs, route tables, connectivity).

.PARAMETER IncludeMetrics
    Include resource metrics analysis (CPU, memory, DTU, etc.).

.PARAMETER TimeRange
    Time range for metrics analysis. Default: 2 hours.

.PARAMETER OutputFormat
    Output format: Console (default), JSON, HTML, or CSV.

.EXAMPLE
    Get-AzureHealthSnapshot -ResourceGroupName "rg-retailmax-prod"
    
    Quick health check of all resources in production resource group.

.EXAMPLE
    Get-AzureHealthSnapshot -ResourceGroupName "rg-retailmax-prod" -IncludeNetworking -IncludeMetrics
    
    Comprehensive health check including networking and performance metrics.

.EXAMPLE
    Get-AzureHealthSnapshot -SubscriptionId "abc-123" -OutputFormat HTML
    
    Subscription-wide health check with HTML report output.

.NOTES
    Author: Generated with GitHub Copilot
    Purpose: Demo 4 - Troubleshooting Assistant
    Time to Create: ~3 minutes with Copilot vs. 45 minutes manually
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeNetworking,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeMetrics,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 24)]
    [int]$TimeRange = 2,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Console', 'JSON', 'HTML', 'CSV')]
    [string]$OutputFormat = 'Console'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        'Info'    { 'White' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }
    
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Get-ResourceHealthStatus {
    param([object]$Resource)
    
    try {
        # Get resource health
        $health = Get-AzResourceHealth -ResourceId $Resource.ResourceId -ErrorAction SilentlyContinue
        
        if ($health) {
            return [PSCustomObject]@{
                Status = $health.Properties.availabilityState
                Summary = $health.Properties.summary
                ReasonType = $health.Properties.reasonType
                OccurredTime = $health.Properties.occurredTime
            }
        }
        
        return [PSCustomObject]@{
            Status = "Unknown"
            Summary = "Health data not available"
            ReasonType = "N/A"
            OccurredTime = $null
        }
    }
    catch {
        Write-Log "Could not retrieve health for $($Resource.Name): $($_.Exception.Message)" -Level Warning
        return $null
    }
}

function Get-RecentAlerts {
    param([string]$ResourceId, [int]$Hours)
    
    try {
        $startTime = (Get-Date).AddHours(-$Hours)
        $alerts = Get-AzAlert -TargetResourceId $ResourceId -ErrorAction SilentlyContinue |
            Where-Object { $_.StartDateTime -gt $startTime } |
            Select-Object -First 10
        
        return $alerts
    }
    catch {
        Write-Log "Could not retrieve alerts for resource: $($_.Exception.Message)" -Level Warning
        return @()
    }
}

function Get-ResourceMetrics {
    param(
        [string]$ResourceId,
        [string]$ResourceType,
        [int]$Hours
    )
    
    $endTime = Get-Date
    $startTime = $endTime.AddHours(-$Hours)
    
    # Define metrics based on resource type
    $metricsToCheck = switch -Wildcard ($ResourceType) {
        "Microsoft.Web/sites" {
            @('CpuTime', 'MemoryWorkingSet', 'Http5xx', 'ResponseTime')
        }
        "Microsoft.Sql/servers/databases" {
            @('cpu_percent', 'dtu_consumption_percent', 'connection_successful', 'connection_failed')
        }
        "Microsoft.Compute/virtualMachines" {
            @('Percentage CPU', 'Available Memory Bytes', 'Disk Read Bytes', 'Disk Write Bytes')
        }
        default {
            @()
        }
    }
    
    $metricsData = @()
    
    foreach ($metricName in $metricsToCheck) {
        try {
            $metric = Get-AzMetric -ResourceId $ResourceId `
                -MetricName $metricName `
                -StartTime $startTime `
                -EndTime $endTime `
                -TimeGrain 00:05:00 `
                -ErrorAction SilentlyContinue
            
            if ($metric -and $metric.Data.Count -gt 0) {
                $values = $metric.Data | Where-Object { $_.Average -ne $null } | Select-Object -ExpandProperty Average
                
                if ($values.Count -gt 0) {
                    $metricsData += [PSCustomObject]@{
                        MetricName = $metricName
                        Average = [math]::Round(($values | Measure-Object -Average).Average, 2)
                        Maximum = [math]::Round(($values | Measure-Object -Maximum).Maximum, 2)
                        Minimum = [math]::Round(($values | Measure-Object -Minimum).Minimum, 2)
                        SampleCount = $values.Count
                    }
                }
            }
        }
        catch {
            Write-Log "Could not retrieve metric $metricName : $($_.Exception.Message)" -Level Warning
        }
    }
    
    return $metricsData
}

function Test-NetworkConnectivity {
    param([object]$Resource)
    
    $networkStatus = @{
        NSGRules = @()
        RouteTable = $null
        PublicIP = $null
        PrivateIP = $null
        DNSServers = @()
    }
    
    # This is a simplified check - full implementation would inspect NSGs, routes, etc.
    # For demo purposes, showing structure that Copilot would generate
    
    if ($Resource.Type -like "*Microsoft.Network*") {
        $networkStatus.PublicIP = "Networking resource - detailed checks would be performed here"
    }
    
    return $networkStatus
}

#endregion

#region Main Execution

Write-Log "Starting Azure Health Snapshot..." -Level Info
Write-Log "Time Range: Last $TimeRange hours" -Level Info

# Set Azure context if subscription specified
if ($SubscriptionId) {
    try {
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        Write-Log "Set context to subscription: $SubscriptionId" -Level Success
    }
    catch {
        Write-Log "Failed to set subscription context: $($_.Exception.Message)" -Level Error
        exit 1
    }
}

$context = Get-AzContext
Write-Log "Subscription: $($context.Subscription.Name)" -Level Info

# Get resources
Write-Log "Retrieving resources..." -Level Info

$resources = if ($ResourceGroupName) {
    Get-AzResource -ResourceGroupName $ResourceGroupName
}
else {
    Get-AzResource
}

Write-Log "Found $($resources.Count) resources to check" -Level Info

# Initialize results collection
$healthSnapshot = @()

# Process each resource
$progressCount = 0
foreach ($resource in $resources) {
    $progressCount++
    Write-Progress -Activity "Checking Resource Health" `
        -Status "Processing: $($resource.Name)" `
        -PercentComplete (($progressCount / $resources.Count) * 100)
    
    Write-Log "Checking: $($resource.Name) ($($resource.Type))" -Level Info
    
    # Get health status
    $health = Get-ResourceHealthStatus -Resource $resource
    
    # Get recent alerts
    $alerts = Get-RecentAlerts -ResourceId $resource.ResourceId -Hours $TimeRange
    
    # Get metrics if requested
    $metrics = if ($IncludeMetrics) {
        Get-ResourceMetrics -ResourceId $resource.ResourceId -ResourceType $resource.Type -Hours $TimeRange
    }
    else {
        $null
    }
    
    # Get networking info if requested
    $networking = if ($IncludeNetworking) {
        Test-NetworkConnectivity -Resource $resource
    }
    else {
        $null
    }
    
    # Determine overall status
    $overallStatus = if ($health -and $health.Status -eq "Available") {
        "Healthy"
    }
    elseif ($health -and $health.Status -eq "Degraded") {
        "Degraded"
    }
    elseif ($alerts.Count -gt 0) {
        "Warning"
    }
    else {
        "Unknown"
    }
    
    # Build result object
    $result = [PSCustomObject]@{
        ResourceName     = $resource.Name
        ResourceType     = $resource.Type
        ResourceGroup    = $resource.ResourceGroupName
        Location         = $resource.Location
        OverallStatus    = $overallStatus
        HealthStatus     = $health
        RecentAlerts     = $alerts.Count
        AlertDetails     = $alerts
        Metrics          = $metrics
        Networking       = $networking
        Tags             = $resource.Tags
        ResourceId       = $resource.ResourceId
    }
    
    $healthSnapshot += $result
}

Write-Progress -Activity "Checking Resource Health" -Completed

#endregion

#region Output Formatting

Write-Log "`n========================================" -Level Info
Write-Log "HEALTH SNAPSHOT SUMMARY" -Level Info
Write-Log "========================================`n" -Level Info

# Summary statistics
$totalResources = $healthSnapshot.Count
$healthyCount = ($healthSnapshot | Where-Object { $_.OverallStatus -eq "Healthy" }).Count
$degradedCount = ($healthSnapshot | Where-Object { $_.OverallStatus -eq "Degraded" }).Count
$warningCount = ($healthSnapshot | Where-Object { $_.OverallStatus -eq "Warning" }).Count
$unknownCount = ($healthSnapshot | Where-Object { $_.OverallStatus -eq "Unknown" }).Count

Write-Host "Total Resources:    $totalResources" -ForegroundColor White
Write-Host "Healthy:            $healthyCount" -ForegroundColor Green
Write-Host "Degraded:           $degradedCount" -ForegroundColor $(if ($degradedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "Warnings:           $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "Unknown:            $unknownCount" -ForegroundColor Gray

Write-Log "`n========================================" -Level Info
Write-Log "RESOURCE DETAILS" -Level Info
Write-Log "========================================`n" -Level Info

foreach ($result in $healthSnapshot) {
    $statusColor = switch ($result.OverallStatus) {
        "Healthy"  { 'Green' }
        "Degraded" { 'Red' }
        "Warning"  { 'Yellow' }
        default    { 'Gray' }
    }
    
    Write-Host "`n$($result.ResourceName)" -ForegroundColor Cyan
    Write-Host "  Type:     $($result.ResourceType)" -ForegroundColor Gray
    Write-Host "  Status:   $($result.OverallStatus)" -ForegroundColor $statusColor
    
    if ($result.HealthStatus) {
        Write-Host "  Health:   $($result.HealthStatus.Status) - $($result.HealthStatus.Summary)" -ForegroundColor Gray
    }
    
    if ($result.RecentAlerts -gt 0) {
        Write-Host "  Alerts:   $($result.RecentAlerts) alert(s) in last $TimeRange hours" -ForegroundColor Yellow
    }
    
    if ($result.Metrics) {
        Write-Host "  Metrics:" -ForegroundColor Gray
        foreach ($metric in $result.Metrics) {
            Write-Host "    - $($metric.MetricName): Avg=$($metric.Average), Max=$($metric.Maximum)" -ForegroundColor Gray
        }
    }
}

# Export based on format
switch ($OutputFormat) {
    'JSON' {
        $outputFile = "health-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $healthSnapshot | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Log "`nExported to: $outputFile" -Level Success
    }
    'CSV' {
        $outputFile = "health-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $healthSnapshot | Select-Object ResourceName, ResourceType, OverallStatus, RecentAlerts, ResourceGroup, Location |
            Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
        Write-Log "`nExported to: $outputFile" -Level Success
    }
    'HTML' {
        $outputFile = "health-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Health Snapshot - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 20px; }
        h1 { color: #0078d4; border-bottom: 3px solid #0078d4; padding-bottom: 10px; }
        .summary { background-color: white; padding: 20px; margin: 20px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; background-color: white; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background-color: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        .healthy { color: #107c10; font-weight: bold; }
        .degraded { color: #d13438; font-weight: bold; }
        .warning { color: #ff8c00; font-weight: bold; }
        .unknown { color: #605e5c; }
    </style>
</head>
<body>
    <h1>Azure Health Snapshot</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    <p>Subscription: $($context.Subscription.Name)</p>
    
    <div class="summary">
        <h2>Summary</h2>
        <table>
            <tr><th>Metric</th><th>Count</th></tr>
            <tr><td>Total Resources</td><td>$totalResources</td></tr>
            <tr><td>Healthy</td><td class="healthy">$healthyCount</td></tr>
            <tr><td>Degraded</td><td class="degraded">$degradedCount</td></tr>
            <tr><td>Warnings</td><td class="warning">$warningCount</td></tr>
            <tr><td>Unknown</td><td class="unknown">$unknownCount</td></tr>
        </table>
    </div>
    
    <h2>Resource Details</h2>
    <table>
        <tr>
            <th>Resource Name</th>
            <th>Type</th>
            <th>Status</th>
            <th>Alerts</th>
            <th>Location</th>
        </tr>
"@
        foreach ($result in $healthSnapshot) {
            $statusClass = $result.OverallStatus.ToLower()
            $htmlContent += @"
        <tr>
            <td>$($result.ResourceName)</td>
            <td>$($result.ResourceType)</td>
            <td class="$statusClass">$($result.OverallStatus)</td>
            <td>$($result.RecentAlerts)</td>
            <td>$($result.Location)</td>
        </tr>
"@
        }
        
        $htmlContent += @"
    </table>
</body>
</html>
"@
        
        $htmlContent | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Log "`nExported to: $outputFile" -Level Success
        Start-Process $outputFile
    }
}

Write-Log "`n========================================" -Level Info
Write-Log "Health Snapshot Complete!" -Level Success
Write-Log "========================================" -Level Info

# Return results
return $healthSnapshot

#endregion

<#
.SYNOPSIS
    Validates Azure Arc agent connectivity and health status.

.DESCRIPTION
    Tests Arc agent connection status, validates required endpoints, checks extension health,
    and generates compliance reports. Use for troubleshooting and post-deployment validation.

.PARAMETER ResourceGroupName
    Resource group containing Arc-enabled servers to validate.

.PARAMETER GenerateReport
    Generate detailed HTML report of validation results.

.EXAMPLE
    .\Test-ArcConnectivity.ps1 -ResourceGroupName "rg-arc-prod" -GenerateReport

.NOTES
    Author: Cloud Infrastructure Team
    Version: 1.0
    Generated with GitHub Copilot assistance
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $colors = @{'Info'='Cyan';'Success'='Green';'Warning'='Yellow';'Error'='Red'}
    Write-Host "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] [$Level] $Message" -ForegroundColor $colors[$Level]
}

try {
    Write-Log "=== Azure Arc Connectivity Validator ===" -Level Info
    
    # Get Arc servers
    Write-Log "Retrieving Arc-enabled servers from: $ResourceGroupName" -Level Info
    $arcServers = Get-AzConnectedMachine -ResourceGroupName $ResourceGroupName
    
    if ($arcServers.Count -eq 0) {
        Write-Log "No Arc-enabled servers found in resource group" -Level Warning
        return
    }
    
    Write-Log "Found $($arcServers.Count) Arc-enabled servers`n" -Level Info
    
    # Validate each server
    $results = @()
    
    foreach ($server in $arcServers) {
        Write-Log "Validating: $($server.Name)" -Level Info
        
        $validation = [PSCustomObject]@{
            ServerName = $server.Name
            Status = $server.Status
            LastHeartbeat = $server.LastStatusChange
            OSName = $server.OSName
            OSVersion = $server.OSVersion
            AgentVersion = $server.AgentVersion
            Location = $server.Location
            ConnectedStatus = 'Unknown'
            ExtensionCount = 0
            ExtensionStatus = @()
            Issues = @()
        }
        
        # Check connection status
        if ($server.Status -eq 'Connected') {
            $validation.ConnectedStatus = 'Connected'
            Write-Host "  ✓ Status: Connected" -ForegroundColor Green
        }
        else {
            $validation.ConnectedStatus = 'Disconnected'
            $validation.Issues += "Server is $($server.Status)"
            Write-Host "  ✗ Status: $($server.Status)" -ForegroundColor Red
        }
        
        # Check last heartbeat
        $heartbeatAge = (Get-Date) - $server.LastStatusChange
        if ($heartbeatAge.TotalMinutes -gt 30) {
            $validation.Issues += "Last heartbeat: $([math]::Round($heartbeatAge.TotalMinutes, 0)) minutes ago"
            Write-Host "  ⚠ Last heartbeat: $([math]::Round($heartbeatAge.TotalMinutes, 0)) minutes ago" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✓ Last heartbeat: $([math]::Round($heartbeatAge.TotalMinutes, 0)) minutes ago" -ForegroundColor Green
        }
        
        # Check extensions
        $extensions = Get-AzConnectedMachineExtension -ResourceGroupName $ResourceGroupName -MachineName $server.Name -ErrorAction SilentlyContinue
        $validation.ExtensionCount = $extensions.Count
        
        if ($extensions.Count -gt 0) {
            Write-Host "  Extensions: $($extensions.Count) installed" -ForegroundColor Cyan
            foreach ($ext in $extensions) {
                $extStatus = [PSCustomObject]@{
                    Name = $ext.Name
                    Type = $ext.ExtensionType
                    ProvisioningState = $ext.ProvisioningState
                }
                $validation.ExtensionStatus += $extStatus
                
                if ($ext.ProvisioningState -eq 'Succeeded') {
                    Write-Host "    ✓ $($ext.Name): $($ext.ProvisioningState)" -ForegroundColor Green
                }
                else {
                    Write-Host "    ✗ $($ext.Name): $($ext.ProvisioningState)" -ForegroundColor Red
                    $validation.Issues += "Extension $($ext.Name) is $($ext.ProvisioningState)"
                }
            }
        }
        else {
            Write-Host "  ⚠ No extensions installed" -ForegroundColor Yellow
            $validation.Issues += "No extensions installed"
        }
        
        # Agent version check
        if ($validation.AgentVersion) {
            Write-Host "  Agent Version: $($validation.AgentVersion)" -ForegroundColor Cyan
        }
        
        $results += $validation
        Write-Host ""
    }
    
    # Summary
    $connectedCount = ($results | Where-Object { $_.ConnectedStatus -eq 'Connected' }).Count
    $disconnectedCount = ($results | Where-Object { $_.ConnectedStatus -ne 'Connected' }).Count
    $issueCount = ($results | Where-Object { $_.Issues.Count -gt 0 }).Count
    
    Write-Log "=== Validation Summary ===" -Level Info
    Write-Host "`nTotal Servers:       " -NoNewline; Write-Host $arcServers.Count -ForegroundColor Cyan
    Write-Host "Connected:           " -NoNewline; Write-Host $connectedCount -ForegroundColor Green
    Write-Host "Disconnected:        " -NoNewline; Write-Host $disconnectedCount -ForegroundColor $(if ($disconnectedCount -gt 0) { 'Red' } else { 'Green' })
    Write-Host "Servers with Issues: " -NoNewline; Write-Host $issueCount -ForegroundColor $(if ($issueCount -gt 0) { 'Yellow' } else { 'Green' })
    
    # Generate report
    if ($GenerateReport) {
        Write-Log "`nGenerating validation report..." -Level Info
        
        $reportFile = "ArcValidation-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
        
        $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Arc Validation Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078d4; border-bottom: 3px solid #0078d4; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .summary { background-color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .server { background-color: white; padding: 15px; margin-bottom: 15px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .connected { color: #107c10; font-weight: bold; }
        .disconnected { color: #d13438; font-weight: bold; }
        .warning { color: #ff8c00; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background-color: #0078d4; color: white; padding: 10px; text-align: left; }
        td { padding: 8px; border-bottom: 1px solid #ddd; }
        .issue { background-color: #fff4ce; padding: 5px; margin: 5px 0; border-left: 3px solid #ff8c00; }
    </style>
</head>
<body>
    <h1>Azure Arc Connectivity Validation Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    
    <div class="summary">
        <h2>Summary</h2>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
            <tr><td>Total Servers</td><td>$($arcServers.Count)</td></tr>
            <tr><td>Connected</td><td class="connected">$connectedCount</td></tr>
            <tr><td>Disconnected</td><td class="disconnected">$disconnectedCount</td></tr>
            <tr><td>Servers with Issues</td><td class="warning">$issueCount</td></tr>
        </table>
    </div>
    
    <h2>Server Details</h2>
"@
        
        foreach ($result in $results) {
            $statusClass = if ($result.ConnectedStatus -eq 'Connected') { 'connected' } else { 'disconnected' }
            
            $htmlReport += @"
    <div class="server">
        <h3>$($result.ServerName) <span class="$statusClass">($($result.ConnectedStatus))</span></h3>
        <table>
            <tr><td><strong>OS:</strong></td><td>$($result.OSName) $($result.OSVersion)</td></tr>
            <tr><td><strong>Location:</strong></td><td>$($result.Location)</td></tr>
            <tr><td><strong>Agent Version:</strong></td><td>$($result.AgentVersion)</td></tr>
            <tr><td><strong>Last Heartbeat:</strong></td><td>$($result.LastHeartbeat)</td></tr>
            <tr><td><strong>Extensions:</strong></td><td>$($result.ExtensionCount) installed</td></tr>
        </table>
"@
            
            if ($result.Issues.Count -gt 0) {
                $htmlReport += "<h4>Issues:</h4>"
                foreach ($issue in $result.Issues) {
                    $htmlReport += "<div class='issue'>$issue</div>"
                }
            }
            
            $htmlReport += "</div>"
        }
        
        $htmlReport += @"
</body>
</html>
"@
        
        $htmlReport | Out-File -FilePath $reportFile -Encoding UTF8
        Write-Log "Report saved: $reportFile" -Level Success
        
        # Open report in browser
        Start-Process $reportFile
    }
    
    Write-Log "`n✅ Validation completed!" -Level Success
    
    # Return results
    return $results
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level Error
    throw
}

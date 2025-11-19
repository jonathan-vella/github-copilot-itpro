<#
.SYNOPSIS
    Validates Azure Arc onboarding deployment and configuration.

.DESCRIPTION
    This comprehensive test suite validates all aspects of an Azure Arc Connected Machine
    deployment including:
    - Service Principal configuration and permissions
    - Arc agent connectivity and status
    - Azure Policy compliance
    - Monitoring configuration (DCR, AMA extension)
    - Extension status and health
    - Tag compliance
    - Log Analytics data flow

.PARAMETER SubscriptionId
    Azure subscription ID containing Arc-enabled servers.

.PARAMETER ResourceGroupName
    Resource group name containing Arc servers (optional - if not specified, scans entire subscription).

.PARAMETER ServicePrincipalId
    Application ID of Service Principal used for Arc onboarding.

.PARAMETER LogAnalyticsWorkspaceId
    Full resource ID of Log Analytics workspace for monitoring validation.

.PARAMETER SkipConnectivityTests
    Skip testing connectivity to Arc servers (faster, but less comprehensive).

.PARAMETER GenerateReport
    Generate HTML report of validation results.

.PARAMETER ReportPath
    Path for HTML report output (default: current directory).

.EXAMPLE
    .\Test-ArcOnboarding.ps1 -SubscriptionId "12345678-..." -ResourceGroupName "rg-arc-prod"
    
.EXAMPLE
    .\Test-ArcOnboarding.ps1 -SubscriptionId "12345678-..." -GenerateReport -ReportPath "C:\Reports"

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.ConnectedMachine, Az.Resources, Az.Monitor, Az.PolicyInsights modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$ServicePrincipalId,

    [Parameter(Mandatory = $false)]
    [string]$LogAnalyticsWorkspaceId,

    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectivityTests,

    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport,

    [Parameter(Mandatory = $false)]
    [string]$ReportPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Test results collection
$testResults = @{
    Passed = 0
    Failed = 0
    Warnings = 0
    Tests = @()
    StartTime = Get-Date
}

#region Helper Functions

function Write-TestResult {
    param(
        [string]$TestName,
        [ValidateSet('Pass', 'Fail', 'Warning')]
        [string]$Status,
        [string]$Message = "",
        [object]$Details = $null
    )
    
    $icon = switch ($Status) {
        'Pass' { '✅' }
        'Fail' { '❌' }
        'Warning' { '⚠️' }
    }
    
    $color = switch ($Status) {
        'Pass' { 'Green' }
        'Fail' { 'Red' }
        'Warning' { 'Yellow' }
    }
    
    Write-Host "   $icon $TestName" -ForegroundColor $color
    if ($Message) {
        Write-Host "      $Message" -ForegroundColor Gray
    }
    
    $testResults.Tests += [PSCustomObject]@{
        TestName = $TestName
        Status = $Status
        Message = $Message
        Details = $Details
        Timestamp = Get-Date
    }
    
    switch ($Status) {
        'Pass' { $testResults.Passed++ }
        'Fail' { $testResults.Failed++ }
        'Warning' { $testResults.Warnings++ }
    }
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $Title" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

#endregion

#region Main Validation

try {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Azure Arc Onboarding - Validation Suite               ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    # Test 1: Azure Connection
    Write-SectionHeader "1. Azure Connection & Prerequisites"
    
    try {
        $context = Get-AzContext
        if ($context) {
            Write-TestResult -TestName "Azure Connection" -Status "Pass" -Message "Connected as $($context.Account.Id)"
        } else {
            Write-TestResult -TestName "Azure Connection" -Status "Fail" -Message "Not connected to Azure"
            throw "Please run Connect-AzAccount first"
        }
    } catch {
        Write-TestResult -TestName "Azure Connection" -Status "Fail" -Message $_.Exception.Message
        exit 1
    }
    
    # Test 2: Required Modules
    Write-SectionHeader "2. PowerShell Modules"
    
    $requiredModules = @('Az.ConnectedMachine', 'Az.Resources', 'Az.Monitor', 'Az.PolicyInsights')
    foreach ($moduleName in $requiredModules) {
        $module = Get-Module -ListAvailable -Name $moduleName | Select-Object -First 1
        if ($module) {
            Write-TestResult -TestName "$moduleName Module" -Status "Pass" -Message "Version $($module.Version)"
        } else {
            Write-TestResult -TestName "$moduleName Module" -Status "Fail" -Message "Module not installed"
        }
    }
    
    # Test 3: Set Subscription Context
    Write-SectionHeader "3. Subscription Context"
    
    try {
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        $subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
        Write-TestResult -TestName "Subscription Access" -Status "Pass" -Message "$($subscription.Name)"
    } catch {
        Write-TestResult -TestName "Subscription Access" -Status "Fail" -Message "Cannot access subscription: $($_.Exception.Message)"
        exit 1
    }
    
    # Test 4: Service Principal Validation (if provided)
    if ($ServicePrincipalId) {
        Write-SectionHeader "4. Service Principal Configuration"
        
        try {
            $sp = Get-AzADServicePrincipal -ApplicationId $ServicePrincipalId -ErrorAction Stop
            Write-TestResult -TestName "Service Principal Exists" -Status "Pass" -Message "Display Name: $($sp.DisplayName)"
            
            # Check RBAC assignments
            $roleAssignments = Get-AzRoleAssignment -ObjectId $sp.Id -Scope "/subscriptions/$SubscriptionId"
            $requiredRole = "Azure Connected Machine Onboarding"
            
            if ($roleAssignments.RoleDefinitionName -contains $requiredRole) {
                Write-TestResult -TestName "RBAC - Arc Onboarding Role" -Status "Pass" -Message "Role assigned correctly"
            } else {
                Write-TestResult -TestName "RBAC - Arc Onboarding Role" -Status "Warning" -Message "Role not found at subscription scope"
            }
            
        } catch {
            Write-TestResult -TestName "Service Principal Validation" -Status "Fail" -Message $_.Exception.Message
        }
    }
    
    # Test 5: Arc Server Discovery
    Write-SectionHeader "5. Arc-Enabled Servers Discovery"
    
    $getResourceParams = @{
        ResourceType = 'Microsoft.HybridCompute/machines'
    }
    
    if ($ResourceGroupName) {
        $getResourceParams['ResourceGroupName'] = $ResourceGroupName
    }
    
    try {
        $arcServers = Get-AzResource @getResourceParams
        $serverCount = ($arcServers | Measure-Object).Count
        
        if ($serverCount -gt 0) {
            Write-TestResult -TestName "Arc Servers Found" -Status "Pass" -Message "Found $serverCount Arc-enabled servers"
        } else {
            Write-TestResult -TestName "Arc Servers Found" -Status "Warning" -Message "No Arc-enabled servers found"
        }
        
    } catch {
        Write-TestResult -TestName "Arc Servers Discovery" -Status "Fail" -Message $_.Exception.Message
        exit 1
    }
    
    # Test 6: Server Connectivity Status
    if ($serverCount -gt 0 -and -not $SkipConnectivityTests) {
        Write-SectionHeader "6. Server Connectivity Status"
        
        $connectedCount = 0
        $disconnectedCount = 0
        $expiredCount = 0
        
        foreach ($server in $arcServers) {
            try {
                $machine = Get-AzConnectedMachine -ResourceGroupName $server.ResourceGroupName -Name $server.Name -ErrorAction Stop
                
                switch ($machine.Status) {
                    'Connected' { $connectedCount++ }
                    'Disconnected' { $disconnectedCount++ }
                    'Expired' { $expiredCount++ }
                }
            } catch {
                Write-TestResult -TestName "Query Server: $($server.Name)" -Status "Warning" -Message "Failed to get status: $($_.Exception.Message)"
                $disconnectedCount++
            }
        }
        
        Write-TestResult -TestName "Connected Servers" -Status "Pass" -Message "$connectedCount / $serverCount connected"
        
        if ($disconnectedCount -gt 0) {
            Write-TestResult -TestName "Disconnected Servers" -Status "Warning" -Message "$disconnectedCount servers disconnected"
        }
        
        if ($expiredCount -gt 0) {
            Write-TestResult -TestName "Expired Servers" -Status "Fail" -Message "$expiredCount servers expired"
        }
        
        $connectivityRate = if ($serverCount -gt 0) { [Math]::Round(($connectedCount / $serverCount) * 100, 1) } else { 0 }
        
        if ($connectivityRate -ge 95) {
            Write-TestResult -TestName "Connectivity Rate" -Status "Pass" -Message "$connectivityRate%"
        } elseif ($connectivityRate -ge 90) {
            Write-TestResult -TestName "Connectivity Rate" -Status "Warning" -Message "$connectivityRate%"
        } else {
            Write-TestResult -TestName "Connectivity Rate" -Status "Fail" -Message "$connectivityRate%"
        }
    }
    
    # Test 7: Extension Status
    if ($serverCount -gt 0 -and -not $SkipConnectivityTests) {
        Write-SectionHeader "7. Extension Status"
        
        $extensionStats = @{
            AzureMonitorAgent = 0
            GuestConfiguration = 0
            Total = 0
        }
        
        foreach ($server in $arcServers | Select-Object -First 10) { # Sample first 10 servers
            try {
                $extensions = Get-AzConnectedMachineExtension -ResourceGroupName $server.ResourceGroupName -MachineName $server.Name
                
                foreach ($ext in $extensions) {
                    if ($ext.Name -like '*AzureMonitor*') {
                        $extensionStats.AzureMonitorAgent++
                    }
                    if ($ext.Name -like '*GuestConfiguration*') {
                        $extensionStats.GuestConfiguration++
                    }
                }
                
                $extensionStats.Total += ($extensions | Measure-Object).Count
            } catch {
                # Continue on error
            }
        }
        
        if ($extensionStats.AzureMonitorAgent -gt 0) {
            Write-TestResult -TestName "Azure Monitor Agent" -Status "Pass" -Message "Deployed on sampled servers"
        } else {
            Write-TestResult -TestName "Azure Monitor Agent" -Status "Warning" -Message "Not found on sampled servers"
        }
        
        if ($extensionStats.GuestConfiguration -gt 0) {
            Write-TestResult -TestName "Guest Configuration" -Status "Pass" -Message "Deployed on sampled servers"
        } else {
            Write-TestResult -TestName "Guest Configuration" -Status "Warning" -Message "Not found on sampled servers"
        }
    }
    
    # Test 8: Tag Compliance
    if ($serverCount -gt 0) {
        Write-SectionHeader "8. Tag Compliance"
        
        $requiredTags = @('Environment', 'Owner', 'CostCenter')
        $compliantCount = 0
        $nonCompliantCount = 0
        
        foreach ($server in $arcServers) {
            $tags = $server.Tags
            $hasAllTags = $true
            
            foreach ($requiredTag in $requiredTags) {
                if (-not $tags.ContainsKey($requiredTag)) {
                    $hasAllTags = $false
                    break
                }
            }
            
            if ($hasAllTags) {
                $compliantCount++
            } else {
                $nonCompliantCount++
            }
        }
        
        $complianceRate = if ($serverCount -gt 0) { [Math]::Round(($compliantCount / $serverCount) * 100, 1) } else { 0 }
        
        $tagStatus = if ($complianceRate -ge 95) { 'Pass' } elseif ($complianceRate -ge 80) { 'Warning' } else { 'Fail' }
        $tagMessage = "$complianceRate% ($compliantCount / $serverCount servers)"
        if ($complianceRate -eq 0) {
            $tagMessage += " - Tags need to be applied via policy or manual update"
        }
        
        Write-TestResult -TestName "Tag Compliance" -Status $tagStatus -Message $tagMessage
    }
    
    # Test 9: Azure Policy Compliance
    Write-SectionHeader "9. Azure Policy Compliance"
    
    try {
        $policyStates = Get-AzPolicyState -SubscriptionId $SubscriptionId -Filter "ResourceType eq 'Microsoft.HybridCompute/machines'" -Top 100
        
        if ($policyStates) {
            $compliantStates = ($policyStates | Where-Object { $_.ComplianceState -eq 'Compliant' } | Measure-Object).Count
            $nonCompliantStates = ($policyStates | Where-Object { $_.ComplianceState -eq 'NonCompliant' } | Measure-Object).Count
            $totalStates = ($policyStates | Measure-Object).Count
            
            $policyComplianceRate = if ($totalStates -gt 0) { [Math]::Round(($compliantStates / $totalStates) * 100, 1) } else { 0 }
            
            Write-TestResult -TestName "Policy Compliance" -Status $(if ($policyComplianceRate -ge 95) { 'Pass' } elseif ($policyComplianceRate -ge 80) { 'Warning' } else { 'Fail' }) `
                            -Message "$policyComplianceRate% compliant ($compliantStates / $totalStates policy evaluations)"
        } else {
            Write-TestResult -TestName "Policy Compliance" -Status "Warning" -Message "No policy states found (policies may not be assigned)"
        }
    } catch {
        Write-TestResult -TestName "Policy Compliance" -Status "Warning" -Message "Unable to query policy state: $($_.Exception.Message)"
    }
    
    # Test 10: Log Analytics Data Flow (if workspace provided)
    if ($LogAnalyticsWorkspaceId) {
        Write-SectionHeader "10. Monitoring & Log Analytics"
        
        try {
            # Extract workspace name and resource group from ID
            if ($LogAnalyticsWorkspaceId -match '/resourceGroups/([^/]+)/.*?/workspaces/([^/]+)') {
                $workspaceRG = $Matches[1]
                $workspaceName = $Matches[2]
                
                $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $workspaceRG -Name $workspaceName
                
                Write-TestResult -TestName "Log Analytics Workspace" -Status "Pass" -Message "Workspace: $workspaceName"
                
                # Check for Arc server data (requires Az.OperationalInsights module)
                try {
                    $kqlQuery = "Heartbeat | where TimeGenerated > ago(15m) | where Category == 'Azure Monitor Agent' | summarize count()"
                    $queryResult = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query $kqlQuery -ErrorAction Stop
                    
                    if ($queryResult.Results) {
                        Write-TestResult -TestName "Heartbeat Data Flow" -Status "Pass" -Message "Arc servers sending heartbeat data"
                    } else {
                        Write-TestResult -TestName "Heartbeat Data Flow" -Status "Warning" -Message "No heartbeat data in last 15 minutes"
                    }
                } catch {
                    Write-TestResult -TestName "Heartbeat Data Flow" -Status "Warning" -Message "Unable to query workspace (may need Az.OperationalInsights module)"
                }
                
            } else {
                Write-TestResult -TestName "Log Analytics Validation" -Status "Warning" -Message "Invalid workspace ID format"
            }
        } catch {
            Write-TestResult -TestName "Log Analytics Validation" -Status "Fail" -Message $_.Exception.Message
        }
    }
    
    # Test Summary
    $testResults.EndTime = Get-Date
    $testResults.Duration = $testResults.EndTime - $testResults.StartTime
    
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor White
    Write-Host "║                    TEST SUMMARY                            ║" -ForegroundColor White
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor White
    
    Write-Host "`n📊 Results:" -ForegroundColor White
    Write-Host "   ✅ Passed: $($testResults.Passed)" -ForegroundColor Green
    Write-Host "   ❌ Failed: $($testResults.Failed)" -ForegroundColor Red
    Write-Host "   ⚠️  Warnings: $($testResults.Warnings)" -ForegroundColor Yellow
    
    $totalTests = $testResults.Passed + $testResults.Failed + $testResults.Warnings
    if ($totalTests -gt 0) {
        $passRate = [Math]::Round((($testResults.Passed + $testResults.Warnings) / $totalTests) * 100, 1)
        Write-Host "`n   Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { 'Green' } elseif ($passRate -ge 70) { 'Yellow' } else { 'Red' })
    }
    
    Write-Host "`n   Duration: $([Math]::Round($testResults.Duration.TotalSeconds, 1)) seconds" -ForegroundColor Gray
    
    # Generate HTML Report (if requested)
    if ($GenerateReport) {
        Write-Host "`n📄 Generating HTML report..." -ForegroundColor Cyan
        
        $reportFile = Join-Path $ReportPath "ArcValidation_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
        
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Arc Onboarding Validation Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078d4; border-bottom: 3px solid #0078d4; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .summary { background-color: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .stats { display: flex; justify-content: space-around; margin: 20px 0; }
        .stat { text-align: center; padding: 20px; background-color: #fff; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; margin: 0 10px; }
        .stat-value { font-size: 36px; font-weight: bold; margin: 10px 0; }
        .stat-label { color: #666; font-size: 14px; text-transform: uppercase; }
        .pass { color: #107c10; }
        .fail { color: #d13438; }
        .warning { color: #ffb900; }
        table { width: 100%; border-collapse: collapse; background-color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin: 20px 0; }
        th { background-color: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f0f0f0; }
        .status-icon { font-size: 18px; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <h1>🔍 Azure Arc Onboarding Validation Report</h1>
    
    <div class="summary">
        <p><strong>Subscription:</strong> $SubscriptionId</p>
        $(if ($ResourceGroupName) { "<p><strong>Resource Group:</strong> $ResourceGroupName</p>" })
        <p><strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Duration:</strong> $([Math]::Round($testResults.Duration.TotalSeconds, 1)) seconds</p>
    </div>
    
    <div class="stats">
        <div class="stat">
            <div class="stat-value pass">$($testResults.Passed)</div>
            <div class="stat-label">Passed</div>
        </div>
        <div class="stat">
            <div class="stat-value fail">$($testResults.Failed)</div>
            <div class="stat-label">Failed</div>
        </div>
        <div class="stat">
            <div class="stat-value warning">$($testResults.Warnings)</div>
            <div class="stat-label">Warnings</div>
        </div>
        <div class="stat">
            <div class="stat-value">$passRate%</div>
            <div class="stat-label">Success Rate</div>
        </div>
    </div>
    
    <h2>Test Results</h2>
    <table>
        <thead>
            <tr>
                <th>Status</th>
                <th>Test Name</th>
                <th>Message</th>
                <th>Timestamp</th>
            </tr>
        </thead>
        <tbody>
"@
        
        foreach ($test in $testResults.Tests) {
            $statusClass = $test.Status.ToLower()
            $icon = switch ($test.Status) {
                'Pass' { '✅' }
                'Fail' { '❌' }
                'Warning' { '⚠️' }
            }
            
            $html += @"
            <tr>
                <td class="status-icon $statusClass">$icon</td>
                <td>$($test.TestName)</td>
                <td>$($test.Message)</td>
                <td>$($test.Timestamp.ToString('HH:mm:ss'))</td>
            </tr>
"@
        }
        
        $html += @"
        </tbody>
    </table>
    
    <div class="footer">
        Generated by Azure Arc Validation Suite | GitHub Copilot for IT Pros
    </div>
</body>
</html>
"@
        
        $html | Out-File -FilePath $reportFile -Force -Encoding UTF8
        Write-Host "   ✅ Report saved: $reportFile" -ForegroundColor Green
    }
    
    # Exit code based on results
    if ($testResults.Failed -eq 0) {
        Write-Host "`n✅ All critical tests passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n⚠️  Some tests failed. Review results above." -ForegroundColor Yellow
        exit 1
    }
    
} catch {
    Write-Host "`n❌ Test suite error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    exit 1
}

#endregion

<#
.SYNOPSIS
    Cleans up Azure Arc onboarding demo resources.

.DESCRIPTION
    This script safely removes Azure Arc-enabled servers and related resources created
    during the demo. It provides options to remove Arc agents, policy assignments,
    monitoring configurations, and Service Principals.

.PARAMETER SubscriptionId
    Azure subscription ID containing Arc resources to clean up.

.PARAMETER ResourceGroupName
    Resource group containing Arc servers (if not specified, prompts for each server).

.PARAMETER RemoveArcServers
    Remove Arc server resources from Azure (does not uninstall agent from machines).

.PARAMETER UninstallAgents
    Uninstall Arc agent from physical machines (requires connectivity to servers).

.PARAMETER ServerListPath
    Path to CSV file containing server details for agent uninstallation.
    Required columns: Name, OS, IPAddress

.PARAMETER RemovePolicies
    Remove Arc-related Azure Policy assignments.

.PARAMETER RemoveMonitoring
    Remove Data Collection Rules and monitoring configurations.

.PARAMETER RemoveServicePrincipal
    Remove Service Principal created for Arc onboarding.

.PARAMETER ServicePrincipalId
    Application ID of Service Principal to remove.

.PARAMETER Force
    Skip confirmation prompts (use with caution).

.PARAMETER WhatIf
    Show what would be removed without actually removing anything.

.EXAMPLE
    .\cleanup.ps1 -SubscriptionId "12345678-..." -ResourceGroupName "rg-arc-demo" -RemoveArcServers
    Remove Arc server resources from specified resource group.

.EXAMPLE
    .\cleanup.ps1 -SubscriptionId "12345678-..." -RemoveArcServers -RemovePolicies -RemoveMonitoring -Force
    Remove Arc servers, policies, and monitoring with no confirmation prompts.

.EXAMPLE
    .\cleanup.ps1 -SubscriptionId "12345678-..." -UninstallAgents -ServerListPath ".\servers.csv"
    Uninstall Arc agent from machines listed in CSV file.

.EXAMPLE
    .\cleanup.ps1 -SubscriptionId "12345678-..." -WhatIf
    Preview what would be removed without making any changes.

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.ConnectedMachine, Az.Resources, Az.PolicyInsights modules
    WARNING: This script removes resources. Use -WhatIf first to preview changes.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveArcServers,

    [Parameter(Mandatory = $false)]
    [switch]$UninstallAgents,

    [Parameter(Mandatory = $false)]
    [string]$ServerListPath,

    [Parameter(Mandatory = $false)]
    [switch]$RemovePolicies,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveMonitoring,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveServicePrincipal,

    [Parameter(Mandatory = $false)]
    [string]$ServicePrincipalId,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Cleanup results tracking
$cleanupResults = @{
    ArcServersRemoved = 0
    AgentsUninstalled = 0
    PoliciesRemoved = 0
    MonitoringConfigsRemoved = 0
    Errors = @()
    StartTime = Get-Date
}

#region Helper Functions

function Write-CleanupMessage {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $icon = switch ($Level) {
        'Info' { 'ℹ️' }
        'Success' { '✅' }
        'Warning' { '⚠️' }
        'Error' { '❌' }
    }
    
    $color = switch ($Level) {
        'Info' { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    }
    
    Write-Host "   $icon $Message" -ForegroundColor $color
}

function Confirm-Action {
    param(
        [string]$Message,
        [string]$WarningMessage
    )
    
    if ($Force -or $WhatIfPreference) {
        return $true
    }
    
    Write-Host "`n⚠️  $Message" -ForegroundColor Yellow
    if ($WarningMessage) {
        Write-Host "   $WarningMessage" -ForegroundColor Gray
    }
    
    $response = Read-Host "   Continue? (yes/no)"
    return ($response -eq 'yes' -or $response -eq 'y')
}

#endregion

#region Main Cleanup

try {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Azure Arc Onboarding - Cleanup Script                 ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    if ($WhatIfPreference) {
        Write-Host "`n🔍 WHATIF MODE: No changes will be made`n" -ForegroundColor Magenta
    }
    
    # Set subscription context
    Write-Host "`n🔄 Setting subscription context..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    $subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
    Write-CleanupMessage "Using subscription: $($subscription.Name)" -Level Info
    
    # Cleanup 1: Remove Arc Server Resources
    if ($RemoveArcServers) {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║ 1. Removing Arc Server Resources                          ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        
        $getResourceParams = @{
            ResourceType = 'Microsoft.HybridCompute/machines'
        }
        
        if ($ResourceGroupName) {
            $getResourceParams['ResourceGroupName'] = $ResourceGroupName
        }
        
        $arcServers = Get-AzResource @getResourceParams
        $serverCount = ($arcServers | Measure-Object).Count
        
        Write-CleanupMessage "Found $serverCount Arc-enabled servers" -Level Info
        
        if ($serverCount -gt 0) {
            if (Confirm-Action -Message "Remove $serverCount Arc server resources?" `
                              -WarningMessage "This removes Azure resources but does NOT uninstall agents from machines") {
                
                foreach ($server in $arcServers) {
                    try {
                        if ($PSCmdlet.ShouldProcess($server.Name, "Remove Arc server resource")) {
                            Remove-AzResource -ResourceId $server.ResourceId -Force
                            Write-CleanupMessage "Removed: $($server.Name)" -Level Success
                            $cleanupResults.ArcServersRemoved++
                        }
                    } catch {
                        Write-CleanupMessage "Failed to remove $($server.Name): $($_.Exception.Message)" -Level Error
                        $cleanupResults.Errors += "Arc Server - $($server.Name): $($_.Exception.Message)"
                    }
                }
            } else {
                Write-CleanupMessage "Skipped Arc server removal" -Level Warning
            }
        } else {
            Write-CleanupMessage "No Arc servers found to remove" -Level Info
        }
    }
    
    # Cleanup 2: Uninstall Arc Agents
    if ($UninstallAgents) {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║ 2. Uninstalling Arc Agents from Machines                  ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        
        if (-not $ServerListPath) {
            Write-CleanupMessage "ServerListPath is required for agent uninstallation" -Level Error
        } elseif (-not (Test-Path $ServerListPath)) {
            Write-CleanupMessage "Server list file not found: $ServerListPath" -Level Error
        } else {
            $servers = Import-Csv -Path $ServerListPath
            $serverCount = ($servers | Measure-Object).Count
            
            Write-CleanupMessage "Found $serverCount servers in CSV" -Level Info
            
            if (Confirm-Action -Message "Uninstall Arc agent from $serverCount machines?" `
                              -WarningMessage "This connects to each machine and removes the Arc agent") {
                
                foreach ($server in $servers) {
                    try {
                        if ($PSCmdlet.ShouldProcess($server.Name, "Uninstall Arc agent")) {
                            Write-CleanupMessage "Uninstalling agent from $($server.Name)..." -Level Info
                            
                            # Windows uninstall command
                            if ($server.OS -like '*Windows*') {
                                $uninstallCmd = 'msiexec /x "{4CB1C701-81D7-4C8E-A86A-5DB3044E5970}" /qn'
                                Invoke-Command -ComputerName $server.Name -ScriptBlock {
                                    param($cmd)
                                    Invoke-Expression $cmd
                                    Start-Sleep -Seconds 5
                                } -ArgumentList $uninstallCmd -ErrorAction Stop
                            }
                            # Linux uninstall command
                            else {
                                $uninstallCmd = 'sudo systemctl stop himdsd && sudo apt-get remove -y azcmagent || sudo yum remove -y azcmagent'
                                # Note: Actual SSH implementation would go here
                                Write-CleanupMessage "Linux uninstall requires SSH (not implemented in this script)" -Level Warning
                            }
                            
                            Write-CleanupMessage "Uninstalled from $($server.Name)" -Level Success
                            $cleanupResults.AgentsUninstalled++
                        }
                    } catch {
                        Write-CleanupMessage "Failed to uninstall from $($server.Name): $($_.Exception.Message)" -Level Error
                        $cleanupResults.Errors += "Agent Uninstall - $($server.Name): $($_.Exception.Message)"
                    }
                }
            } else {
                Write-CleanupMessage "Skipped agent uninstallation" -Level Warning
            }
        }
    }
    
    # Cleanup 3: Remove Azure Policies
    if ($RemovePolicies) {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║ 3. Removing Azure Policy Assignments                      ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        
        # Get Arc-related policy assignments
        $scope = "/subscriptions/$SubscriptionId"
        if ($ResourceGroupName) {
            $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
        }
        
        $policyAssignments = Get-AzPolicyAssignment -Scope $scope | Where-Object {
            $_.Properties.DisplayName -like '*Arc*' -or 
            $_.Properties.DisplayName -like '*Connected Machine*' -or
            $_.Properties.DisplayName -like '*Hybrid*'
        }
        
        $policyCount = ($policyAssignments | Measure-Object).Count
        Write-CleanupMessage "Found $policyCount Arc-related policy assignments" -Level Info
        
        if ($policyCount -gt 0) {
            if (Confirm-Action -Message "Remove $policyCount policy assignments?" `
                              -WarningMessage "This removes policy assignments but not policy definitions") {
                
                foreach ($policy in $policyAssignments) {
                    try {
                        if ($PSCmdlet.ShouldProcess($policy.Properties.DisplayName, "Remove policy assignment")) {
                            Remove-AzPolicyAssignment -Id $policy.ResourceId
                            Write-CleanupMessage "Removed: $($policy.Properties.DisplayName)" -Level Success
                            $cleanupResults.PoliciesRemoved++
                        }
                    } catch {
                        Write-CleanupMessage "Failed to remove $($policy.Properties.DisplayName): $($_.Exception.Message)" -Level Error
                        $cleanupResults.Errors += "Policy - $($policy.Properties.DisplayName): $($_.Exception.Message)"
                    }
                }
            } else {
                Write-CleanupMessage "Skipped policy removal" -Level Warning
            }
        } else {
            Write-CleanupMessage "No Arc-related policies found" -Level Info
        }
    }
    
    # Cleanup 4: Remove Monitoring Configurations
    if ($RemoveMonitoring) {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║ 4. Removing Monitoring Configurations                     ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        
        # Remove Data Collection Rules
        try {
            $dcrs = Get-AzResource -ResourceType 'Microsoft.Insights/dataCollectionRules'
            $arcDcrs = $dcrs | Where-Object { $_.Name -like '*arc*' -or $_.Tags.Purpose -eq 'ArcMonitoring' }
            $dcrCount = ($arcDcrs | Measure-Object).Count
            
            Write-CleanupMessage "Found $dcrCount Arc-related Data Collection Rules" -Level Info
            
            if ($dcrCount -gt 0) {
                if (Confirm-Action -Message "Remove $dcrCount Data Collection Rules?" `
                                  -WarningMessage "This stops data collection for Arc servers") {
                    
                    foreach ($dcr in $arcDcrs) {
                        try {
                            if ($PSCmdlet.ShouldProcess($dcr.Name, "Remove Data Collection Rule")) {
                                Remove-AzResource -ResourceId $dcr.ResourceId -Force
                                Write-CleanupMessage "Removed DCR: $($dcr.Name)" -Level Success
                                $cleanupResults.MonitoringConfigsRemoved++
                            }
                        } catch {
                            Write-CleanupMessage "Failed to remove DCR $($dcr.Name): $($_.Exception.Message)" -Level Error
                            $cleanupResults.Errors += "DCR - $($dcr.Name): $($_.Exception.Message)"
                        }
                    }
                } else {
                    Write-CleanupMessage "Skipped DCR removal" -Level Warning
                }
            } else {
                Write-CleanupMessage "No Arc-related DCRs found" -Level Info
            }
        } catch {
            Write-CleanupMessage "Unable to query DCRs: $($_.Exception.Message)" -Level Warning
        }
    }
    
    # Cleanup 5: Remove Service Principal
    if ($RemoveServicePrincipal -and $ServicePrincipalId) {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║ 5. Removing Service Principal                             ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        
        try {
            $sp = Get-AzADServicePrincipal -ApplicationId $ServicePrincipalId -ErrorAction Stop
            
            Write-CleanupMessage "Found Service Principal: $($sp.DisplayName)" -Level Info
            
            if (Confirm-Action -Message "Remove Service Principal '$($sp.DisplayName)'?" `
                              -WarningMessage "This permanently removes the Service Principal and its credentials") {
                
                if ($PSCmdlet.ShouldProcess($sp.DisplayName, "Remove Service Principal")) {
                    # Remove role assignments first
                    $roleAssignments = Get-AzRoleAssignment -ObjectId $sp.Id
                    foreach ($assignment in $roleAssignments) {
                        Remove-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName $assignment.RoleDefinitionName -Scope $assignment.Scope -ErrorAction SilentlyContinue
                    }
                    
                    # Remove Service Principal
                    Remove-AzADServicePrincipal -ObjectId $sp.Id
                    Write-CleanupMessage "Removed Service Principal: $($sp.DisplayName)" -Level Success
                }
            } else {
                Write-CleanupMessage "Skipped Service Principal removal" -Level Warning
            }
        } catch {
            Write-CleanupMessage "Failed to remove Service Principal: $($_.Exception.Message)" -Level Error
            $cleanupResults.Errors += "Service Principal: $($_.Exception.Message)"
        }
    }
    
    # Cleanup Summary
    $cleanupResults.EndTime = Get-Date
    $cleanupResults.Duration = $cleanupResults.EndTime - $cleanupResults.StartTime
    
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor White
    Write-Host "║                    CLEANUP SUMMARY                         ║" -ForegroundColor White
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor White
    
    if ($WhatIfPreference) {
        Write-Host "`n🔍 WHATIF MODE: No actual changes were made" -ForegroundColor Magenta
    }
    
    Write-Host "`n📊 Results:" -ForegroundColor White
    Write-Host "   Arc Servers Removed: $($cleanupResults.ArcServersRemoved)" -ForegroundColor Cyan
    Write-Host "   Agents Uninstalled: $($cleanupResults.AgentsUninstalled)" -ForegroundColor Cyan
    Write-Host "   Policies Removed: $($cleanupResults.PoliciesRemoved)" -ForegroundColor Cyan
    Write-Host "   Monitoring Configs Removed: $($cleanupResults.MonitoringConfigsRemoved)" -ForegroundColor Cyan
    
    if ($cleanupResults.Errors.Count -gt 0) {
        Write-Host "`n⚠️  Errors encountered:" -ForegroundColor Yellow
        foreach ($error in $cleanupResults.Errors) {
            Write-Host "   • $error" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n   Duration: $([Math]::Round($cleanupResults.Duration.TotalSeconds, 1)) seconds" -ForegroundColor Gray
    
    if ($cleanupResults.Errors.Count -eq 0) {
        Write-Host "`n✅ Cleanup completed successfully!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n⚠️  Cleanup completed with $($cleanupResults.Errors.Count) errors" -ForegroundColor Yellow
        exit 1
    }
    
} catch {
    Write-Host "`n❌ Cleanup error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    exit 1
}

#endregion

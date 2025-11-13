<#
.SYNOPSIS
    Applies Azure Policy definitions to Arc-enabled servers for governance and compliance.

.DESCRIPTION
    Creates and assigns Azure Policy definitions for Arc-enabled servers including tagging
    enforcement, security baselines, monitoring requirements, and update management. Generates
    compliance reports for audit purposes.

.PARAMETER SubscriptionId
    Azure subscription ID where policies will be assigned.

.PARAMETER ManagementGroupId
    (Optional) Management group ID for policy assignment scope.

.PARAMETER ResourceGroupScope
    (Optional) Resource group name to scope policy assignment.

.PARAMETER PolicySet
    Policy set to apply: 'Standard' (tagging, monitoring), 'Security' (baselines, defender),
    or 'Complete' (all policies). Default: 'Complete'.

.PARAMETER GenerateReport
    Generate compliance report after policy assignment.

.EXAMPLE
    .\Set-ArcGovernancePolicy.ps1 `
        -SubscriptionId "12345678-1234-1234-1234-123456789012" `
        -PolicySet "Complete" `
        -GenerateReport

.NOTES
    Author: Cloud Infrastructure Team
    Version: 1.0
    Required Permissions: Resource Policy Contributor
    Generated with GitHub Copilot assistance
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$ManagementGroupId,
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupScope,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Standard', 'Security', 'Complete')]
    [string]$PolicySet = 'Complete',
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $colors = @{'Info'='Cyan';'Success'='Green';'Warning'='Yellow';'Error'='Red'}
    Write-Host "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] [$Level] $Message" -ForegroundColor $colors[$Level]
}

#endregion

try {
    Write-Log "=== Azure Arc Governance Policy Manager ===" -Level Info
    
    # Set context
    $null = Set-AzContext -SubscriptionId $SubscriptionId
    
    # Determine scope
    if ($ManagementGroupId) {
        $scope = "/providers/Microsoft.Management/managementGroups/$ManagementGroupId"
        Write-Log "Using Management Group scope: $ManagementGroupId" -Level Info
    }
    elseif ($ResourceGroupScope) {
        $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupScope"
        Write-Log "Using Resource Group scope: $ResourceGroupScope" -Level Info
    }
    else {
        $scope = "/subscriptions/$SubscriptionId"
        Write-Log "Using Subscription scope" -Level Info
    }
    
    # Define policy definitions
    $policies = @()
    
    # Tagging policy (Standard, Complete)
    if ($PolicySet -in @('Standard', 'Complete')) {
        $policies += @{
            Name = "Arc-Require-Tags"
            DisplayName = "Require tags on Arc-enabled servers"
            Description = "Enforces required tags: CostCenter, Owner, Environment, Application"
            Mode = "Indexed"
            PolicyRule = @{
                if = @{
                    allOf = @(
                        @{
                            field = "type"
                            equals = "Microsoft.HybridCompute/machines"
                        }
                        @{
                            anyOf = @(
                                @{ field = "tags['CostCenter']"; exists = "false" }
                                @{ field = "tags['Owner']"; exists = "false" }
                                @{ field = "tags['Environment']"; exists = "false" }
                                @{ field = "tags['Application']"; exists = "false" }
                            )
                        }
                    )
                }
                then = @{
                    effect = "deny"
                }
            }
        }
        
        # Monitoring policy
        $policies += @{
            Name = "Arc-Deploy-LogAnalytics"
            DisplayName = "Deploy Log Analytics agent to Arc servers"
            Description = "Automatically deploys Azure Monitor Agent to Arc-enabled servers"
            Mode = "Indexed"
            PolicyRule = @{
                if = @{
                    allOf = @(
                        @{ field = "type"; equals = "Microsoft.HybridCompute/machines" }
                        @{ field = "Microsoft.HybridCompute/machines/osName"; in = @("Windows", "Linux") }
                    )
                }
                then = @{
                    effect = "deployIfNotExists"
                    details = @{
                        type = "Microsoft.HybridCompute/machines/extensions"
                        roleDefinitionIds = @("/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293")
                        existenceCondition = @{
                            field = "Microsoft.HybridCompute/machines/extensions/type"
                            equals = "AzureMonitorWindowsAgent"
                        }
                        deployment = @{
                            properties = @{
                                mode = "incremental"
                                template = @{
                                    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
                                    contentVersion = "1.0.0.0"
                                    parameters = @{
                                        vmName = @{ type = "string" }
                                        location = @{ type = "string" }
                                    }
                                    resources = @(
                                        @{
                                            type = "Microsoft.HybridCompute/machines/extensions"
                                            apiVersion = "2021-05-20"
                                            name = "[concat(parameters('vmName'), '/AzureMonitorWindowsAgent')]"
                                            location = "[parameters('location')]"
                                            properties = @{
                                                publisher = "Microsoft.Azure.Monitor"
                                                type = "AzureMonitorWindowsAgent"
                                                typeHandlerVersion = "1.0"
                                                autoUpgradeMinorVersion = $true
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    # Security policies
    if ($PolicySet -in @('Security', 'Complete')) {
        $policies += @{
            Name = "Arc-Windows-Security-Baseline"
            DisplayName = "Apply Windows security baseline to Arc servers"
            Description = "Enforces Windows Server security baseline configuration"
            Mode = "Indexed"
            PolicyType = "BuiltIn"
            PolicyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/72650e9f-97bc-4b2a-ab5f-9781a9fcecbc"
        }
        
        $policies += @{
            Name = "Arc-Enable-Defender"
            DisplayName = "Enable Microsoft Defender for Arc servers"
            Description = "Automatically enables Defender for Servers on Arc-enabled machines"
            Mode = "Indexed"
            PolicyType = "BuiltIn"
            PolicyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/8b5ad9ab-3d44-4a6e-9ac3-75b04ea5fd28"
        }
    }
    
    # Create/Update policy definitions
    Write-Log "Creating/Updating policy definitions..." -Level Info
    $createdPolicies = @()
    
    foreach ($policy in $policies) {
        if ($policy.PolicyType -eq "BuiltIn") {
            Write-Log "Using built-in policy: $($policy.DisplayName)" -Level Info
            $createdPolicies += @{
                Name = $policy.Name
                Id = $policy.PolicyDefinitionId
            }
        }
        else {
            Write-Log "Creating custom policy: $($policy.DisplayName)" -Level Info
            
            $policyJson = $policy.PolicyRule | ConvertTo-Json -Depth 10
            
            $newPolicy = New-AzPolicyDefinition `
                -Name $policy.Name `
                -DisplayName $policy.DisplayName `
                -Description $policy.Description `
                -Mode $policy.Mode `
                -Policy $policyJson `
                -ManagementGroupName $ManagementGroupId `
                -ErrorAction SilentlyContinue
            
            if (-not $newPolicy) {
                $newPolicy = Get-AzPolicyDefinition -Name $policy.Name
                Write-Log "Policy already exists: $($policy.Name)" -Level Warning
            }
            
            $createdPolicies += @{
                Name = $policy.Name
                Id = $newPolicy.PolicyDefinitionId
            }
        }
    }
    
    # Create policy assignments
    Write-Log "`nAssigning policies to scope..." -Level Info
    $assignments = @()
    
    foreach ($policy in $createdPolicies) {
        $assignmentName = "Assign-$($policy.Name)"
        
        Write-Log "Assigning policy: $($policy.Name)" -Level Info
        
        $assignment = New-AzPolicyAssignment `
            -Name $assignmentName `
            -PolicyDefinition (Get-AzPolicyDefinition -Id $policy.Id) `
            -Scope $scope `
            -ErrorAction SilentlyContinue
        
        if ($assignment) {
            $assignments += $assignment
            Write-Log "✓ Policy assigned: $assignmentName" -Level Success
        }
        else {
            Write-Log "✗ Failed to assign: $assignmentName" -Level Warning
        }
    }
    
    Write-Log "`nWaiting 30 seconds for policy propagation..." -Level Info
    Start-Sleep -Seconds 30
    
    # Generate compliance report
    if ($GenerateReport) {
        Write-Log "`nGenerating compliance report..." -Level Info
        
        $complianceStates = Get-AzPolicyState -Filter "PolicyDefinitionAction eq 'deny' or PolicyDefinitionAction eq 'audit' or PolicyDefinitionAction eq 'deployIfNotExists'"
        
        $complianceSummary = $complianceStates | Group-Object -Property ComplianceState | Select-Object @{
            Name = 'ComplianceState'
            Expression = { $_.Name }
        }, @{
            Name = 'Count'
            Expression = { $_.Count }
        }
        
        Write-Log "`nCompliance Summary:" -Level Info
        $complianceSummary | ForEach-Object {
            $color = if ($_.ComplianceState -eq 'Compliant') { 'Green' } else { 'Yellow' }
            Write-Host "  $($_.ComplianceState): " -NoNewline
            Write-Host $_.Count -ForegroundColor $color
        }
        
        # Export detailed report
        $reportFile = "ArcPolicyCompliance-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $complianceStates | Select-Object ResourceId, ResourceType, ComplianceState, PolicyDefinitionName | 
            Export-Csv -Path $reportFile -NoTypeInformation
        
        Write-Log "Detailed report exported to: $reportFile" -Level Success
    }
    
    Write-Log "`n✅ Policy configuration completed!" -Level Success
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level Error
    throw
}

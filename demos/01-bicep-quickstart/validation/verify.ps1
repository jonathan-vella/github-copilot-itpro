<#
.SYNOPSIS
    Validates the deployed Bicep Quickstart demo infrastructure.

.DESCRIPTION
    This script verifies that all resources from Demo 01 are deployed correctly
    and configured according to best practices. It checks:
    - Resource group exists
    - Virtual network and subnets
    - Network Security Groups and rules
    - Storage account and security settings

.PARAMETER ResourceGroupName
    The name of the Azure resource group to validate.

.EXAMPLE
    .\verify.ps1 -ResourceGroupName "rg-copilot-demo-01"
    
    Validates all resources in the specified resource group.

.NOTES
    Author: GitHub Copilot IT Pro Demo
    Requires: Azure CLI, PowerShell 7+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Color output functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    
    $colorMap = @{
        'Green'  = 'Green'
        'Yellow' = 'Yellow'
        'Red'    = 'Red'
        'Cyan'   = 'Cyan'
        'Gray'   = 'Gray'
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" -Color Green
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" -Color Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" -Color Red
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n🔍 $Message" -Color Cyan
}

# Validation counters
$script:PassedChecks = 0
$script:FailedChecks = 0
$script:WarningChecks = 0

function Test-Check {
    param(
        [string]$Description,
        [scriptblock]$Test,
        [switch]$IsWarning
    )
    
    try {
        $result = & $Test
        if ($result) {
            Write-Success $Description
            $script:PassedChecks++
            return $true
        }
        else {
            if ($IsWarning) {
                Write-Warning $Description
                $script:WarningChecks++
            }
            else {
                Write-ErrorMessage $Description
                $script:FailedChecks++
            }
            return $false
        }
    }
    catch {
        if ($IsWarning) {
            Write-Warning "$Description - $_"
            $script:WarningChecks++
        }
        else {
            Write-ErrorMessage "$Description - $_"
            $script:FailedChecks++
        }
        return $false
    }
}

# Banner
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║  Bicep Quickstart Demo - Infrastructure Validation       ║" -Color Cyan
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" -Color Cyan
Write-Host ""

# Step 1: Prerequisites
Write-Step "Checking prerequisites..."

Test-Check "Azure CLI is installed" {
    $azVersion = az version --output json 2>$null | ConvertFrom-Json
    if ($azVersion) {
        Write-Host "  Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Gray
        return $true
    }
    return $false
}

Test-Check "Logged into Azure" {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if ($account) {
        Write-Host "  Logged in as: $($account.user.name)" -ForegroundColor Gray
        Write-Host "  Subscription: $($account.name)" -ForegroundColor Gray
        return $true
    }
    return $false
}

# Step 2: Resource Group
Write-Step "Validating resource group..."

$resourceGroup = $null
Test-Check "Resource group '$ResourceGroupName' exists" {
    $script:resourceGroup = az group show --name $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($resourceGroup) {
        Write-Host "  Location: $($resourceGroup.location)" -ForegroundColor Gray
        Write-Host "  State: $($resourceGroup.properties.provisioningState)" -ForegroundColor Gray
        return $true
    }
    return $false
}

if (-not $resourceGroup) {
    Write-ErrorMessage "Cannot proceed without resource group. Exiting."
    exit 1
}

# Step 3: List all resources
Write-Step "Discovering resources..."

$resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
Write-Host "  Found $($resources.Count) resources" -ForegroundColor Gray

# Step 4: Virtual Network
Write-Step "Validating virtual network..."

$vnet = $resources | Where-Object { $_.type -eq 'Microsoft.Network/virtualNetworks' } | Select-Object -First 1

Test-Check "Virtual network exists" {
    return $null -ne $vnet
}

if ($vnet) {
    $vnetDetails = az network vnet show --ids $vnet.id --output json | ConvertFrom-Json
    
    Test-Check "VNet has address space 10.0.0.0/16" {
        return $vnetDetails.addressSpace.addressPrefixes -contains '10.0.0.0/16'
    }
    
    Test-Check "VNet has 3 subnets" {
        $subnetCount = $vnetDetails.subnets.Count
        Write-Host "  Subnet count: $subnetCount" -ForegroundColor Gray
        return $subnetCount -eq 3
    }
    
    $expectedSubnets = @(
        @{ Name = 'snet-web-*'; Prefix = '10.0.1.0/24' }
        @{ Name = 'snet-app-*'; Prefix = '10.0.2.0/24' }
        @{ Name = 'snet-data-*'; Prefix = '10.0.3.0/24' }
    )
    
    foreach ($expected in $expectedSubnets) {
        $subnet = $vnetDetails.subnets | Where-Object { $_.name -like $expected.Name }
        Test-Check "Subnet '$($expected.Name)' exists with prefix $($expected.Prefix)" {
            if ($subnet) {
                Write-Host "  Found: $($subnet.name) - $($subnet.addressPrefix)" -ForegroundColor Gray
                return $subnet.addressPrefix -eq $expected.Prefix
            }
            return $false
        }
    }
}

# Step 5: Network Security Groups
Write-Step "Validating Network Security Groups..."

$nsgs = $resources | Where-Object { $_.type -eq 'Microsoft.Network/networkSecurityGroups' }

Test-Check "Network Security Groups exist" {
    $nsgCount = $nsgs.Count
    Write-Host "  NSG count: $nsgCount" -ForegroundColor Gray
    return $nsgCount -ge 2
}

foreach ($nsg in $nsgs) {
    $nsgDetails = az network nsg show --ids $nsg.id --output json | ConvertFrom-Json
    
    Test-Check "NSG '$($nsg.name)' has security rules" {
        $ruleCount = $nsgDetails.securityRules.Count
        Write-Host "  $($nsg.name): $ruleCount rules" -ForegroundColor Gray
        return $ruleCount -gt 0
    }
    
    # Check for deny-all rule
    $denyRule = $nsgDetails.securityRules | Where-Object { 
        $_.access -eq 'Deny' -and $_.direction -eq 'Inbound' -and $_.priority -ge 4000 
    }
    
    Test-Check "NSG '$($nsg.name)' has deny-all inbound rule" -IsWarning {
        if ($denyRule) {
            Write-Host "  Deny rule priority: $($denyRule.priority)" -ForegroundColor Gray
            return $true
        }
        return $false
    }
}

# Step 6: Storage Account
Write-Step "Validating storage account..."

$storageAccount = $resources | Where-Object { $_.type -eq 'Microsoft.Storage/storageAccounts' } | Select-Object -First 1

Test-Check "Storage account exists" {
    return $null -ne $storageAccount
}

if ($storageAccount) {
    $storageDetails = az storage account show --ids $storageAccount.id --output json | ConvertFrom-Json
    
    Test-Check "Storage account HTTPS-only is enabled" {
        return $storageDetails.enableHttpsTrafficOnly -eq $true
    }
    
    Test-Check "Storage account minimum TLS version is 1.2" {
        $tlsVersion = $storageDetails.minimumTlsVersion
        Write-Host "  TLS Version: $tlsVersion" -ForegroundColor Gray
        return $tlsVersion -eq 'TLS1_2'
    }
    
    Test-Check "Storage account public blob access is disabled" {
        return $storageDetails.allowBlobPublicAccess -eq $false
    }
    
    Test-Check "Storage account has tags" -IsWarning {
        if ($storageDetails.tags) {
            $tagCount = ($storageDetails.tags.PSObject.Properties | Measure-Object).Count
            Write-Host "  Tag count: $tagCount" -ForegroundColor Gray
            return $tagCount -gt 0
        }
        return $false
    }
    
    # Check blob service properties
    $blobService = az storage account blob-service-properties show `
        --account-name $storageDetails.name `
        --resource-group $ResourceGroupName `
        --output json 2>$null | ConvertFrom-Json
    
    if ($blobService) {
        Test-Check "Blob soft delete is enabled" -IsWarning {
            $deleteRetentionPolicy = $blobService.deleteRetentionPolicy
            if ($deleteRetentionPolicy.enabled) {
                Write-Host "  Retention days: $($deleteRetentionPolicy.days)" -ForegroundColor Gray
                return $true
            }
            return $false
        }
    }
}

# Step 7: Resource Tags
Write-Step "Validating resource tags..."

$requiredTags = @('Environment', 'ManagedBy')
$taggedResources = 0
$totalResources = $resources.Count

foreach ($resource in $resources) {
    if ($resource.tags) {
        $tagCount = ($resource.tags.PSObject.Properties | Measure-Object).Count
        if ($tagCount -gt 0) {
            $taggedResources++
        }
    }
}

Test-Check "At least 80% of resources have tags" -IsWarning {
    $percentage = [math]::Round(($taggedResources / $totalResources) * 100, 0)
    Write-Host "  Tagged resources: $taggedResources / $totalResources ($percentage%)" -ForegroundColor Gray
    return $percentage -ge 80
}

# Step 8: Deployments
Write-Step "Validating deployments..."

$deployments = az deployment group list --resource-group $ResourceGroupName --output json | ConvertFrom-Json

Test-Check "At least one deployment exists" {
    $deploymentCount = $deployments.Count
    Write-Host "  Deployment count: $deploymentCount" -ForegroundColor Gray
    return $deploymentCount -gt 0
}

if ($deployments.Count -gt 0) {
    $latestDeployment = $deployments | Sort-Object -Property { $_.properties.timestamp } -Descending | Select-Object -First 1
    
    Test-Check "Latest deployment succeeded" {
        $state = $latestDeployment.properties.provisioningState
        Write-Host "  Latest deployment: $($latestDeployment.name)" -ForegroundColor Gray
        Write-Host "  State: $state" -ForegroundColor Gray
        Write-Host "  Duration: $($latestDeployment.properties.duration)" -ForegroundColor Gray
        return $state -eq 'Succeeded'
    }
}

# Step 9: Connectivity Tests (Optional)
Write-Step "Validating connectivity (optional)..."

if ($vnet -and $storageAccount) {
    # Check if storage account has network rules
    $storageDetails = az storage account show --ids $storageAccount.id --output json | ConvertFrom-Json
    
    Test-Check "Storage account network rules configured" -IsWarning {
        $networkRules = $storageDetails.networkRuleSet
        if ($networkRules) {
            Write-Host "  Default action: $($networkRules.defaultAction)" -ForegroundColor Gray
            return $true
        }
        return $false
    }
}

# Summary
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║  Validation Summary                                       ║" -Color Cyan
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" -Color Cyan
Write-Host ""

Write-Success "Passed: $PassedChecks checks"
if ($WarningChecks -gt 0) {
    Write-Warning "Warnings: $WarningChecks checks (non-critical)"
}
if ($FailedChecks -gt 0) {
    Write-ErrorMessage "Failed: $FailedChecks checks"
}

Write-Host ""

# Overall result
if ($FailedChecks -eq 0) {
    Write-ColorOutput "🎉 All critical validation checks passed!" -Color Green
    Write-Host ""
    Write-Host "Your infrastructure is deployed correctly and follows best practices."
    Write-Host ""
    
    if ($WarningChecks -gt 0) {
        Write-Host "Note: Some optional best practices were not met (warnings above)." -ForegroundColor Yellow
        Write-Host "These are recommendations and don't affect core functionality." -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "Next Steps:"
    Write-Host "  1. Review resources in Azure Portal: https://portal.azure.com"
    Write-Host "  2. Test application connectivity"
    Write-Host "  3. Configure monitoring and alerts"
    Write-Host "  4. Review security settings"
    Write-Host ""
    Write-Host "When done, clean up resources:"
    Write-Host "  .\cleanup.ps1 -ResourceGroupName '$ResourceGroupName'" -ForegroundColor Cyan
    Write-Host ""
    
    exit 0
}
else {
    Write-ColorOutput "❌ Validation failed with $FailedChecks critical issues" -Color Red
    Write-Host ""
    Write-Host "Please review the failed checks above and fix the issues."
    Write-Host ""
    Write-Host "Common troubleshooting steps:"
    Write-Host "  1. Verify the deployment completed successfully"
    Write-Host "  2. Check Azure Portal for resource status"
    Write-Host "  3. Review deployment logs: az deployment group list --resource-group $ResourceGroupName"
    Write-Host "  4. Re-run the deployment: .\deploy.ps1 -ResourceGroupName '$ResourceGroupName'"
    Write-Host ""
    
    exit 1
}

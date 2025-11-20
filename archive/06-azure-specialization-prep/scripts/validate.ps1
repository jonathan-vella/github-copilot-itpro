# validate.ps1 - Validate Azure Infrastructure Deployment
# Purpose: Tests deployed infrastructure for correct configuration and connectivity
# Usage: .\validate.ps1 -ResourceGroupName "rg-taskmanager-prod"

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================
# FUNCTIONS
# ============================================

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Details = ""
    )
    
    if ($Passed) {
        Write-Host "   ✅ $TestName" -ForegroundColor Green
        if ($Details) {
            Write-Host "      $Details" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "   ❌ $TestName" -ForegroundColor Red
        if ($Details) {
            Write-Host "      $Details" -ForegroundColor Yellow
        }
        $script:failedTests++
    }
}

function Test-ResourceExists {
    param(
        [string]$ResourceType,
        [string]$ResourceName
    )
    
    try {
        $resource = az resource show --resource-group $ResourceGroupName --resource-type $ResourceType --name $ResourceName --output json 2>$null | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

# ============================================
# MAIN SCRIPT
# ============================================

$script:failedTests = 0
$script:passedTests = 0

Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   Infrastructure Validation                                   ║
║   Contoso Task Manager - Deployment Verification             ║
╚═══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Validating: $ResourceGroupName`n" -ForegroundColor White

# Get resource group
Write-Host "🔍 Checking Resource Group..." -ForegroundColor Cyan
try {
    $rg = az group show --name $ResourceGroupName --output json | ConvertFrom-Json
    Write-TestResult -TestName "Resource group exists" -Passed $true -Details "Location: $($rg.location)"
    $script:passedTests++
}
catch {
    Write-TestResult -TestName "Resource group exists" -Passed $false -Details "Resource group not found"
    exit 1
}

# List all resources
$resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json

Write-Host "`n📦 Resource Inventory ($($resources.Count) resources):" -ForegroundColor Cyan
$resources | Group-Object type | ForEach-Object {
    Write-Host "   • $($_.Name): $($_.Count)" -ForegroundColor Gray
}

# Test Virtual Network
Write-Host "`n🌐 Testing Network Infrastructure..." -ForegroundColor Cyan

$vnets = $resources | Where-Object { $_.type -eq 'Microsoft.Network/virtualNetworks' }
if ($vnets.Count -gt 0) {
    $vnet = az network vnet show --resource-group $ResourceGroupName --name $vnets[0].name --output json | ConvertFrom-Json
    Write-TestResult -TestName "Virtual Network deployed" -Passed $true -Details "$($vnet.name) - $($vnet.addressSpace.addressPrefixes[0])"
    $script:passedTests++
    
    # Test Subnets
    $subnetCount = $vnet.subnets.Count
    Write-TestResult -TestName "Subnets configured" -Passed ($subnetCount -ge 2) -Details "$subnetCount subnets found"
    if ($subnetCount -ge 2) { $script:passedTests++ }
    
    # Test NSGs
    foreach ($subnet in $vnet.subnets) {
        $hasNsg = $null -ne $subnet.networkSecurityGroup
        Write-TestResult -TestName "NSG attached to $($subnet.name)" -Passed $hasNsg
        if ($hasNsg) { $script:passedTests++ }
    }
}
else {
    Write-TestResult -TestName "Virtual Network deployed" -Passed $false
}

# Test Public IP
$publicIps = $resources | Where-Object { $_.type -eq 'Microsoft.Network/publicIPAddresses' }
if ($publicIps.Count -gt 0) {
    $pip = az network public-ip show --resource-group $ResourceGroupName --name $publicIps[0].name --output json | ConvertFrom-Json
    Write-TestResult -TestName "Public IP allocated" -Passed $true -Details "$($pip.ipAddress) (FQDN: $($pip.dnsSettings.fqdn))"
    $script:passedTests++
    
    $publicIpAddress = $pip.ipAddress
}
else {
    Write-TestResult -TestName "Public IP allocated" -Passed $false
}

# Test Load Balancer
Write-Host "`n⚖️  Testing Load Balancer..." -ForegroundColor Cyan

$lbs = $resources | Where-Object { $_.type -eq 'Microsoft.Network/loadBalancers' }
if ($lbs.Count -gt 0) {
    $lb = az network lb show --resource-group $ResourceGroupName --name $lbs[0].name --output json | ConvertFrom-Json
    Write-TestResult -TestName "Load Balancer deployed" -Passed $true -Details "$($lb.name) - $($lb.sku.name) SKU"
    $script:passedTests++
    
    # Test Backend Pool
    $backendPoolSize = ($lb.backendAddressPools[0].backendIPConfigurations | Measure-Object).Count
    Write-TestResult -TestName "Backend pool configured" -Passed ($backendPoolSize -gt 0) -Details "$backendPoolSize VMs in pool"
    if ($backendPoolSize -gt 0) { $script:passedTests++ }
    
    # Test Health Probe
    $probeCount = ($lb.probes | Measure-Object).Count
    Write-TestResult -TestName "Health probes configured" -Passed ($probeCount -gt 0) -Details "$probeCount probe(s)"
    if ($probeCount -gt 0) { $script:passedTests++ }
}
else {
    Write-TestResult -TestName "Load Balancer deployed" -Passed $false
}

# Test Virtual Machines
Write-Host "`n💻 Testing Virtual Machines..." -ForegroundColor Cyan

$vms = $resources | Where-Object { $_.type -eq 'Microsoft.Compute/virtualMachines' }
Write-TestResult -TestName "VMs deployed" -Passed ($vms.Count -ge 2) -Details "$($vms.Count) VMs found"
if ($vms.Count -ge 2) { $script:passedTests++ }

foreach ($vmResource in $vms) {
    $vm = az vm show --resource-group $ResourceGroupName --name $vmResource.name --output json | ConvertFrom-Json
    
    # Test VM Power State
    $vmStatus = az vm get-instance-view --resource-group $ResourceGroupName --name $vmResource.name --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" --output tsv
    $isRunning = $vmStatus -eq 'VM running'
    Write-TestResult -TestName "$($vm.name) is running" -Passed $isRunning -Details $vmStatus
    if ($isRunning) { $script:passedTests++ }
    
    # Test VM Extensions
    $extensions = $vm.resources | Where-Object { $_.type -eq 'Microsoft.Compute/virtualMachines/extensions' }
    $hasIIS = $extensions | Where-Object { $_.name -like '*InstallIIS*' }
    Write-TestResult -TestName "$($vm.name) has IIS extension" -Passed ($null -ne $hasIIS)
    if ($null -ne $hasIIS) { $script:passedTests++ }
}

# Test Availability Set
$availSets = $resources | Where-Object { $_.type -eq 'Microsoft.Compute/availabilitySets' }
if ($availSets.Count -gt 0) {
    $availSet = az vm availability-set show --resource-group $ResourceGroupName --name $availSets[0].name --output json | ConvertFrom-Json
    Write-TestResult -TestName "Availability Set configured" -Passed $true -Details "FD: $($availSet.platformFaultDomainCount), UD: $($availSet.platformUpdateDomainCount)"
    $script:passedTests++
}

# Test SQL Server
Write-Host "`n🗄️  Testing SQL Database..." -ForegroundColor Cyan

$sqlServers = az sql server list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
if ($sqlServers.Count -gt 0) {
    $sqlServer = $sqlServers[0]
    Write-TestResult -TestName "SQL Server deployed" -Passed $true -Details "$($sqlServer.fullyQualifiedDomainName)"
    $script:passedTests++
    
    # Test TLS Version
    $tlsOk = $sqlServer.minimalTlsVersion -eq '1.2'
    Write-TestResult -TestName "Minimum TLS 1.2 enforced" -Passed $tlsOk -Details "Version: $($sqlServer.minimalTlsVersion)"
    if ($tlsOk) { $script:passedTests++ }
    
    # Test Databases
    $databases = az sql db list --resource-group $ResourceGroupName --server $sqlServer.name --output json | ConvertFrom-Json
    $appDbs = $databases | Where-Object { $_.name -ne 'master' }
    Write-TestResult -TestName "Application database created" -Passed ($appDbs.Count -gt 0) -Details "$($appDbs[0].name) - $($appDbs[0].sku.name)"
    if ($appDbs.Count -gt 0) { $script:passedTests++ }
    
    # Test Firewall Rules
    $fwRules = az sql server firewall-rule list --resource-group $ResourceGroupName --server $sqlServer.name --output json | ConvertFrom-Json
    Write-TestResult -TestName "Firewall rules configured" -Passed ($fwRules.Count -gt 0) -Details "$($fwRules.Count) rule(s)"
    if ($fwRules.Count -gt 0) { $script:passedTests++ }
}
else {
    Write-TestResult -TestName "SQL Server deployed" -Passed $false
}

# Test Log Analytics
Write-Host "`n📊 Testing Monitoring..." -ForegroundColor Cyan

$workspaces = az monitor log-analytics workspace list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
if ($workspaces.Count -gt 0) {
    Write-TestResult -TestName "Log Analytics workspace deployed" -Passed $true -Details "$($workspaces[0].name)"
    $script:passedTests++
}
else {
    Write-TestResult -TestName "Log Analytics workspace deployed" -Passed $false
}

# Test Application Insights
$appInsights = $resources | Where-Object { $_.type -eq 'microsoft.insights/components' }
if ($appInsights.Count -gt 0) {
    Write-TestResult -TestName "Application Insights configured" -Passed $true -Details "$($appInsights[0].name)"
    $script:passedTests++
}
else {
    Write-TestResult -TestName "Application Insights configured" -Passed $false
}

# Test HTTP Connectivity
if ($publicIpAddress) {
    Write-Host "`n🌍 Testing Application Connectivity..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://$publicIpAddress" -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        $httpOk = $response.StatusCode -eq 200
        Write-TestResult -TestName "HTTP endpoint accessible" -Passed $httpOk -Details "Status: $($response.StatusCode)"
        if ($httpOk) { $script:passedTests++ }
    }
    catch {
        Write-TestResult -TestName "HTTP endpoint accessible" -Passed $false -Details "Error: $($_.Exception.Message)"
    }
}

# Test Tags
Write-Host "`n🏷️  Testing Resource Organization..." -ForegroundColor Cyan

$taggedResources = $resources | Where-Object { $_.tags.Count -gt 0 }
$tagPercentage = [math]::Round(($taggedResources.Count / $resources.Count) * 100)
Write-TestResult -TestName "Resources have tags" -Passed ($tagPercentage -gt 80) -Details "$tagPercentage% tagged"
if ($tagPercentage -gt 80) { $script:passedTests++ }

# Required tags check
$requiredTags = @('Environment', 'Project', 'ManagedBy')
$hasRequiredTags = $true
foreach ($tag in $requiredTags) {
    $resourcesWithTag = $resources | Where-Object { $_.tags.$tag }
    if ($resourcesWithTag.Count -lt $resources.Count * 0.8) {
        $hasRequiredTags = $false
        break
    }
}
Write-TestResult -TestName "Required tags present" -Passed $hasRequiredTags -Details "Environment, Project, ManagedBy"
if ($hasRequiredTags) { $script:passedTests++ }

# Summary
$totalTests = $script:passedTests + $script:failedTests
$successRate = [math]::Round(($script:passedTests / $totalTests) * 100)

Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   VALIDATION SUMMARY                                          ║
╚═══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor $(if ($script:failedTests -eq 0) { 'Green' } else { 'Yellow' })

Write-Host "   Passed: $script:passedTests / $totalTests tests ($successRate%)" -ForegroundColor $(if ($script:failedTests -eq 0) { 'Green' } else { 'Yellow' })

if ($script:failedTests -eq 0) {
    Write-Host @"

   ✅ All validation tests passed!
   
   Infrastructure is ready for:
   1. Application deployment
   2. Database schema initialization
   3. Production workload testing
   
"@ -ForegroundColor Green
    exit 0
}
else {
    Write-Host @"

   ⚠️  $script:failedTests test(s) failed
   
   Review failed tests above and take corrective action.
   Common issues:
   - VM extensions may still be installing (wait 5-10 minutes)
   - Network connectivity requires NSG rule updates
   - Resources may still be provisioning
   
"@ -ForegroundColor Yellow
    exit 1
}

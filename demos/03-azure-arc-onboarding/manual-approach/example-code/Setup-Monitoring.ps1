# Script to setup monitoring for Arc servers
# Manual approach - basic configuration

param(
    [string]$SubscriptionId,
    [string]$ResourceGroup,
    [string]$WorkspaceName = "LogAnalytics-Arc"
)

# Connect
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Create Log Analytics workspace
Write-Host "Creating Log Analytics workspace..."
$workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup `
    -Name $WorkspaceName `
    -Location "eastus" `
    -Sku "PerGB2018"

Write-Host "Workspace created: $($workspace.CustomerId)"

# Get Arc servers
Write-Host "Finding Arc servers..."
$arcServers = Get-AzConnectedMachine -ResourceGroupName $ResourceGroup

# Install monitoring extension on each server
foreach ($server in $arcServers) {
    Write-Host "Installing monitoring on: $($server.Name)"
    
    # This is a simplified example - actual extension installation is more complex
    Write-Host "  Extension installation would go here"
    Write-Host "  (Manual process in Azure Portal is easier)"
}

Write-Host "`nWorkspace ID: $($workspace.CustomerId)"
Write-Host "Configure extensions manually in Azure Portal for each server"
Write-Host "Add performance counters and logs in workspace settings"

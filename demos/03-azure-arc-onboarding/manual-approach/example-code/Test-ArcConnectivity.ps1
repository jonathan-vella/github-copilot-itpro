# Basic connectivity test for Arc servers
# Manual approach - simple checks

param(
    [string]$SubscriptionId,
    [string]$ResourceGroup
)

# Connect
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Get Arc servers
Write-Host "Checking Arc servers in resource group: $ResourceGroup`n"
$servers = Get-AzConnectedMachine -ResourceGroupName $ResourceGroup

if ($servers.Count -eq 0) {
    Write-Host "No Arc servers found"
    exit
}

Write-Host "Found $($servers.Count) servers:`n"

# List servers
foreach ($server in $servers) {
    Write-Host "Server: $($server.Name)"
    Write-Host "  Status: $($server.Status)"
    Write-Host "  OS: $($server.OsName)"
    Write-Host "  Last seen: $($server.LastStatusChange)"
    Write-Host ""
}

Write-Host "Check complete"
Write-Host "For detailed status, use Azure Portal"

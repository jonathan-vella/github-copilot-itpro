# Script to install Arc agent on servers
# Manual approach - sequential installation, basic error handling

param(
    [string[]]$ServerList = @("server1", "server2", "server3"),
    [string]$TenantId,
    [string]$SubscriptionId,
    [string]$ResourceGroup,
    [string]$Location = "eastus",
    [string]$AppId,
    [string]$AppSecret
)

Write-Host "Starting Arc agent installation on servers..."

# Loop through each server
foreach ($server in $ServerList) {
    Write-Host "`nProcessing: $server"
    
    # Check if server is online
    $ping = Test-Connection -ComputerName $server -Count 1 -Quiet
    if (-not $ping) {
        Write-Host "ERROR: Cannot reach $server - skipping"
        continue
    }
    
    # Copy installer to server
    Write-Host "Copying installer..."
    $installerPath = "\\$server\C$\Temp\AzureConnectedMachineAgent.msi"
    Copy-Item -Path ".\AzureConnectedMachineAgent.msi" -Destination $installerPath -Force
    
    # Install agent via remote PowerShell
    Write-Host "Installing agent..."
    Invoke-Command -ComputerName $server -ScriptBlock {
        param($path, $tid, $sid, $rg, $loc, $aid, $secret)
        
        # Install MSI
        Start-Process msiexec.exe -Wait -ArgumentList "/i $path /quiet"
        
        # Connect to Azure Arc
        & 'C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe' connect `
            --tenant-id $tid `
            --subscription-id $sid `
            --resource-group $rg `
            --location $loc `
            --service-principal-id $aid `
            --service-principal-secret $secret
            
    } -ArgumentList $installerPath, $TenantId, $SubscriptionId, $ResourceGroup, $Location, $AppId, $AppSecret
    
    Write-Host "Completed: $server"
}

Write-Host "`nInstallation process finished"
Write-Host "Check Azure Portal to verify servers are showing up"

# Basic script to create Service Principal for Arc onboarding
# Manual approach - minimal error handling and documentation

param(
    [string]$SPName = "ArcServicePrincipal",
    [string]$SubscriptionId,
    [string]$ResourceGroup
)

# Connect to Azure
Connect-AzAccount

# Set subscription
Set-AzContext -SubscriptionId $SubscriptionId

# Create Service Principal
Write-Host "Creating Service Principal..."
$sp = New-AzADServicePrincipal -DisplayName $SPName

# Assign role at subscription level
Write-Host "Assigning role..."
New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Contributor" -Scope "/subscriptions/$SubscriptionId"

# Wait for role assignment to propagate
Write-Host "Waiting 60 seconds for role propagation..."
Start-Sleep -Seconds 60

# Display credentials
Write-Host "`nService Principal created:"
Write-Host "Application ID: $($sp.AppId)"
Write-Host "Secret: (Check Azure portal or use Get-AzADAppCredential)"
Write-Host "`nIMPORTANT: Copy these values before closing this window!"
Write-Host "Save to a text file manually"

Write-Host "`nDone"

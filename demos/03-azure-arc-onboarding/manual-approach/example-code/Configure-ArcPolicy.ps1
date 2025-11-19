# Script to configure Azure Policy for Arc servers
# Manual approach - basic policy assignment

param(
    [string]$SubscriptionId,
    [string]$ResourceGroup,
    [string]$PolicyName = "Arc-Monitoring-Policy"
)

# Connect and set context
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Create policy assignment for Log Analytics
Write-Host "Creating policy assignment..."

$policyDef = Get-AzPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq "Deploy Log Analytics agent to Windows Azure Arc machines"}

if ($policyDef) {
    $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup"
    
    New-AzPolicyAssignment -Name $PolicyName `
        -PolicyDefinition $policyDef `
        -Scope $scope
    
    Write-Host "Policy assigned"
} else {
    Write-Host "ERROR: Policy definition not found"
}

Write-Host "`nManually configure workspace ID in policy parameters via Azure Portal"
Write-Host "Wait 30-60 minutes for policy to take effect"

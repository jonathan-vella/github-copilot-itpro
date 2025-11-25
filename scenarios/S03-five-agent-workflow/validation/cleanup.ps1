$ErrorActionPreference = 'Stop'
$ResourceGroupName = "rg-contoso-patient-portal-dev"

Write-Host "Cleaning up resources..." -ForegroundColor Cyan
if (az group exists --name $ResourceGroupName) {
    Write-Host "Deleting resource group: $ResourceGroupName" -ForegroundColor Yellow
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host "Deletion initiated." -ForegroundColor Green
}
else {
    Write-Host "Resource group $ResourceGroupName does not exist." -ForegroundColor Yellow
}

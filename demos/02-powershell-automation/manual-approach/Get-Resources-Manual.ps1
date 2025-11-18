# Manual PowerShell Script - Basic Resource Report
# Written without GitHub Copilot assistance
# Demonstrates typical manual development approach

# Basic parameter setup
param(
    [string]$SubscriptionId,
    [string]$OutputPath = "."
)

# Connect to Azure
Write-Host "Connecting to Azure..." -ForegroundColor Yellow
try {
    Connect-AzAccount
    Set-AzContext -SubscriptionId $SubscriptionId
}
catch {
    Write-Host "Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Get all resources (no filtering)
Write-Host "Getting resources..." -ForegroundColor Yellow
$resources = Get-AzResource

# Create simple array for output
$output = @()
foreach ($resource in $resources) {
    $obj = New-Object PSObject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Name" -Value $resource.Name
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Type" -Value $resource.ResourceType
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "ResourceGroup" -Value $resource.ResourceGroupName
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Location" -Value $resource.Location
    
    $output += $obj
}

# Export to CSV (basic)
$filename = "resources.csv"
$output | Export-Csv -Path (Join-Path $OutputPath $filename) -NoTypeInformation

Write-Host "Done. Exported to $filename" -ForegroundColor Green

# Issues with this manual approach:
# 1. No comment-based help
# 2. No parameter validation
# 3. No progress indicators
# 4. Basic error handling
# 5. Hard-coded filename (no timestamp)
# 6. Using older New-Object syntax instead of [PSCustomObject]
# 7. No logging
# 8. No options for output format
# 9. No tag information included
# 10. No summary statistics
# 11. Takes longer to write and debug
# 12. Less maintainable code

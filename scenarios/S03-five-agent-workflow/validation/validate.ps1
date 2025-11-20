$ErrorActionPreference = 'Stop'

$result = @{
    Status  = "Passed"
    Content = "Passed"
    Prompts = "Passed"
    Infra   = "Passed"
    Notes   = @()
}

# 1. Content Validation
$requiredFiles = @("README.md", "DEMO-SCRIPT.md")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$PSScriptRoot/../$file")) {
        $result.Content = "Failed"
        $result.Status = "Failed"
        $result.Notes += "Missing file: $file"
    }
}

# 2. Prompts Validation
if (-not (Test-Path "$PSScriptRoot/../prompts/workflow-prompts.md")) {
    $result.Prompts = "Failed"
    $result.Status = "Failed"
    $result.Notes += "Missing prompts/workflow-prompts.md"
}

# 3. Infra Validation (Bicep Lint on the shared infra folder)
$infraPath = Resolve-Path "$PSScriptRoot/../../../infra/bicep/contoso-patient-portal"
if (-not (Test-Path $infraPath)) {
    $result.Infra = "Failed"
    $result.Status = "Failed"
    $result.Notes += "Infra folder not found at $infraPath"
}
else {
    if (Get-Command bicep -ErrorAction SilentlyContinue) {
        $mainBicep = Join-Path $infraPath "main.bicep"
        if (Test-Path $mainBicep) {
            # Capture stderr as well
            $lintOutput = $null
            try {
                $lintOutput = bicep lint $mainBicep 2>&1
            }
            catch {
                $lintOutput = $_.Exception.Message
            }
            
            if ($lintOutput -match "Error") {
                $result.Infra = "Failed"
                $result.Status = "Failed"
                $result.Notes += "Bicep lint errors in main.bicep"
            }
        }
        else {
            $result.Infra = "Failed"
            $result.Status = "Failed"
            $result.Notes += "main.bicep not found in infra folder"
        }
    }
    else {
        $result.Infra = "Warning"
        $result.Notes += "Bicep CLI not installed, skipping lint"
    }
}

# 4. Deployed Resources Validation
$result.Deployment = "Passed"
$resourceGroupName = "rg-contoso-patient-portal-dev"

if (Get-Command az -ErrorAction SilentlyContinue) {
    # Check if resource group exists
    $rgExists = az group exists --name $resourceGroupName 2>$null
    if ($rgExists -eq "true") {
        # Get list of deployed resources
        $resources = az resource list --resource-group $resourceGroupName --query "[].{name:name, type:type}" -o json 2>$null | ConvertFrom-Json
        
        if ($resources.Count -eq 0) {
            $result.Deployment = "Failed"
            $result.Status = "Failed"
            $result.Notes += "No resources found in $resourceGroupName"
        }
        else {
            # Expected resource types
            $expectedTypes = @(
                'Microsoft.Network/virtualNetworks',
                'Microsoft.Network/networkSecurityGroups',
                'Microsoft.KeyVault/vaults',
                'Microsoft.Sql/servers',
                'Microsoft.Sql/servers/databases',
                'Microsoft.Web/serverfarms',
                'Microsoft.Web/sites',
                'Microsoft.Insights/components',
                'Microsoft.OperationalInsights/workspaces'
            )
            
            $deployedTypes = $resources | Select-Object -ExpandProperty type -Unique
            $missingTypes = $expectedTypes | Where-Object { $_ -notin $deployedTypes }
            
            if ($missingTypes.Count -gt 0) {
                $result.Deployment = "Warning"
                $result.Notes += "Missing expected resource types: $($missingTypes -join ', ')"
            }
            
            $result.Notes += "Found $($resources.Count) resources in $resourceGroupName"
        }
    }
    else {
        $result.Deployment = "Failed"
        $result.Status = "Failed"
        $result.Notes += "Resource group $resourceGroupName does not exist"
    }
}
else {
    $result.Deployment = "Skipped"
    $result.Notes += "Azure CLI not installed, skipping deployment validation"
}

# Return JSON
$result | ConvertTo-Json -Compress
<#
.SYNOPSIS
    Generates a CycloneDX SBOM from Azure infrastructure resources.

.DESCRIPTION
    This script queries Azure Resource Graph to inventory all resources in a resource group
    or subscription. It extracts resource types, SKUs, API versions, and configurations,
    generating a CycloneDX 1.5 SBOM for cloud infrastructure components.

.PARAMETER ResourceGroupName
    Name of the Azure resource group to scan.

.PARAMETER SubscriptionId
    Azure subscription ID (uses current context if not specified).

.PARAMETER OutputPath
    Path where the SBOM JSON file will be saved.

.PARAMETER IncludeProperties
    Include detailed resource properties in SBOM (default: $false).

.EXAMPLE
    .\New-InfrastructureSBOM.ps1 -ResourceGroupName "rg-patient-portal-prod" -OutputPath "../examples/infrastructure-sbom.json"

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+, Azure CLI authenticated
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [bool]$IncludeProperties = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "☁️  Generating Azure Infrastructure SBOM..." -ForegroundColor Cyan

try {
    # Check Azure CLI is authenticated
    Write-Verbose "Checking Azure CLI authentication..."
    $account = az account show 2>&1 | ConvertFrom-Json
    
    if (-not $account) {
        Write-Error "Not authenticated to Azure. Run 'az login' first."
        exit 1
    }

    if ($SubscriptionId) {
        az account set --subscription $SubscriptionId | Out-Null
        Write-Host "📌 Using subscription: $SubscriptionId" -ForegroundColor Cyan
    } else {
        Write-Host "📌 Using subscription: $($account.name)" -ForegroundColor Cyan
    }

    # Query resources using Azure Resource Graph
    Write-Host "🔍 Querying resources in: $ResourceGroupName..." -ForegroundColor Yellow
    
    $query = @"
Resources
| where resourceGroup =~ '$ResourceGroupName'
| project name, type, location, sku, properties, apiVersion=properties.apiVersion, id
"@

    $resources = az graph query -q $query --query "data" 2>&1 | ConvertFrom-Json

    if (-not $resources -or $resources.Count -eq 0) {
        Write-Warning "No resources found in resource group: $ResourceGroupName"
        Write-Warning "Ensure the resource group exists and contains resources."
    }

    Write-Host "✅ Found $($resources.Count) resources" -ForegroundColor Green

    # Build SBOM structure
    $sbom = [ordered]@{
        bomFormat    = "CycloneDX"
        specVersion  = "1.5"
        serialNumber = "urn:uuid:$([guid]::NewGuid().ToString())"
        version      = 1
        metadata     = [ordered]@{
            timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            tools     = @(
                [ordered]@{
                    vendor  = "GitHub Copilot"
                    name    = "New-InfrastructureSBOM.ps1"
                    version = "1.0.0"
                }
            )
            component = [ordered]@{
                type        = "platform"
                name        = $ResourceGroupName
                description = "Azure Resource Group"
            }
        }
        components   = @()
    }

    # Process each resource
    foreach ($resource in $resources) {
        Write-Verbose "Processing: $($resource.name) ($($resource.type))"
        
        # Determine API version (fallback if not in properties)
        $apiVersion = "2023-01-01"  # Default fallback
        
        # Common API versions by resource type
        $apiVersionMap = @{
            "Microsoft.Web/sites"             = "2023-12-01"
            "Microsoft.DocumentDB/databaseAccounts" = "2023-11-15"
            "Microsoft.KeyVault/vaults"       = "2023-07-01"
            "Microsoft.Network/virtualNetworks" = "2023-09-01"
            "Microsoft.Insights/components"   = "2020-02-02"
            "Microsoft.Sql/servers"           = "2023-08-01-preview"
        }
        
        if ($apiVersionMap.ContainsKey($resource.type)) {
            $apiVersion = $apiVersionMap[$resource.type]
        }

        # Build component
        $component = [ordered]@{
            type      = "platform"
            "bom-ref" = "pkg:azure/$($resource.type)@$apiVersion"
            name      = $resource.name
            version   = $apiVersion
            purl      = "pkg:azure/$($resource.type)@$apiVersion"
            properties = @(
                [ordered]@{
                    name  = "resourceType"
                    value = $resource.type
                },
                [ordered]@{
                    name  = "location"
                    value = $resource.location
                }
            )
        }

        # Add SKU if available
        if ($resource.sku) {
            $component.properties += [ordered]@{
                name  = "sku"
                value = if ($resource.sku.name) { $resource.sku.name } else { $resource.sku }
            }
        }

        # Add resource ID
        $component.properties += [ordered]@{
            name  = "resourceId"
            value = $resource.id
        }

        $sbom.components += $component
    }

    # Create output directory
    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # Write SBOM
    $sbom | ConvertTo-Json -Depth 15 | Set-Content -Path $OutputPath -Encoding UTF8

    Write-Host "💾 SBOM saved to: $OutputPath" -ForegroundColor Green
    Write-Host "📊 Summary:" -ForegroundColor Cyan
    Write-Host "   - Format: CycloneDX 1.5" -ForegroundColor White
    Write-Host "   - Azure Resources: $($resources.Count)" -ForegroundColor White
    Write-Host "   - Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host ""
    
    # Display resource types
    $resourceTypes = $resources | Group-Object type | Sort-Object Count -Descending
    Write-Host "📦 Resource Types:" -ForegroundColor Cyan
    foreach ($rt in $resourceTypes) {
        Write-Host "   - $($rt.Name): $($rt.Count)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "✨ Infrastructure SBOM generation complete!" -ForegroundColor Green

} catch {
    Write-Error "Failed to generate infrastructure SBOM: $_"
    if ($_.Exception.Message -match "az: command not found") {
        Write-Host "💡 Azure CLI is not installed. Install from: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    }
    exit 1
}

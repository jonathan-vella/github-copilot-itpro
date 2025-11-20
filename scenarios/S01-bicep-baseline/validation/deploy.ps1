<#
.SYNOPSIS
    Deploy the Bicep Quickstart demo infrastructure to Azure.

.DESCRIPTION
    This script deploys a three-tier network infrastructure with secure storage
    to an Azure resource group. It validates the Bicep template, creates the
    resource group if needed, and deploys all resources.

.PARAMETER ResourceGroupName
    Name of the Azure resource group to create or use.

.PARAMETER Location
    Azure region for the deployment (e.g., 'eastus', 'westus2').

.PARAMETER Environment
    Environment name (dev, staging, prod). Default is 'demo'.

.PARAMETER SkipValidation
    Skip Bicep template validation before deployment.

.EXAMPLE
    .\deploy.ps1 -ResourceGroupName "rg-copilot-demo" -Location "eastus"

.EXAMPLE
    .\deploy.ps1 -ResourceGroupName "rg-prod" -Location "eastus" -Environment "prod"

.NOTES
    Author: GitHub Copilot Demo
    Prerequisites:
    - Azure CLI installed and logged in
    - Bicep CLI installed
    - Appropriate Azure permissions (Contributor or Owner on subscription)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Location,

    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'staging', 'prod', 'demo')]
    [string]$Environment = 'demo',

    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation
)

# Set strict mode and error action preference
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path (Split-Path -Parent $ScriptDir) "solution"
$MainBicepFile = Join-Path $TemplateDir "main.bicep"

# Colors for output
$ColorSuccess = 'Green'
$ColorWarning = 'Yellow'
$ColorError = 'Red'
$ColorInfo = 'Cyan'

#region Helper Functions

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White',
        [switch]$NoNewline
    )
    
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    }
    else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n▶ $Message" -Color $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" -Color $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" -Color $ColorWarning
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" -Color $ColorError
}

#endregion

#region Main Script

try {
    Write-ColorOutput @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║    Bicep Quickstart Demo - Infrastructure Deployment          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@ -Color $ColorInfo

    # Step 1: Verify prerequisites
    Write-Step "Checking prerequisites..."

    # Check Azure CLI
    try {
        $azVersion = az version --output json 2>$null | ConvertFrom-Json
        Write-Success "Azure CLI version: $($azVersion.'azure-cli')"
    }
    catch {
        Write-ErrorMessage "Azure CLI not found. Please install: https://aka.ms/installazurecli"
        exit 1
    }

    # Check Bicep CLI
    try {
        $bicepVersion = bicep --version 2>$null
        Write-Success "Bicep version: $bicepVersion"
    }
    catch {
        Write-ErrorMessage "Bicep CLI not found. Please install: az bicep install"
        exit 1
    }

    # Check Azure login
    Write-Step "Verifying Azure login..."
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-ErrorMessage "Not logged into Azure. Please run: az login"
        exit 1
    }
    Write-Success "Logged in as: $($account.user.name)"
    Write-Success "Subscription: $($account.name) ($($account.id))"

    # Step 2: Validate Bicep template
    if (-not $SkipValidation) {
        Write-Step "Validating Bicep template..."
        
        if (-not (Test-Path $MainBicepFile)) {
            Write-ErrorMessage "Main Bicep file not found: $MainBicepFile"
            exit 1
        }

        $buildResult = bicep build $MainBicepFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Bicep validation failed:"
            Write-Host $buildResult
            exit 1
        }
        Write-Success "Bicep template validated successfully"
    }
    else {
        Write-Warning "Skipping Bicep validation (--SkipValidation flag set)"
    }

    # Step 3: Create resource group if it doesn't exist
    Write-Step "Checking resource group: $ResourceGroupName..."
    
    $rgExists = az group exists --name $ResourceGroupName --output tsv
    if ($rgExists -eq 'true') {
        Write-Success "Resource group exists"
        $rg = az group show --name $ResourceGroupName --output json | ConvertFrom-Json
        Write-Host "  Location: $($rg.location)"
        Write-Host "  Tags: $($rg.tags | ConvertTo-Json -Compress)"
    }
    else {
        Write-Step "Creating resource group: $ResourceGroupName in $Location..."
        az group create --name $ResourceGroupName --location $Location --tags "Environment=$Environment" "ManagedBy=Bicep" "Demo=BicepQuickstart" --output none
        
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Failed to create resource group"
            exit 1
        }
        Write-Success "Resource group created"
    }

    # Step 4: Validate deployment
    Write-Step "Validating Azure deployment..."
    
    $validateParams = @(
        'deployment', 'group', 'validate',
        '--resource-group', $ResourceGroupName,
        '--template-file', $MainBicepFile,
        '--parameters', "environment=$Environment", "location=$Location",
        '--output', 'json'
    )
    
    $validationResult = & az @validateParams 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Deployment validation failed:"
        Write-Host $validationResult
        exit 1
    }
    Write-Success "Deployment validation passed"

    # Step 5: Deploy infrastructure
    Write-Step "Deploying infrastructure to Azure..."
    Write-Host "  Resource Group: $ResourceGroupName"
    Write-Host "  Environment: $Environment"
    Write-Host "  Location: $Location"
    Write-Host ""
    Write-Warning "This will deploy Azure resources. Estimated time: 3-5 minutes."
    Write-Host ""

    $deployParams = @(
        'deployment', 'group', 'create',
        '--resource-group', $ResourceGroupName,
        '--template-file', $MainBicepFile,
        '--parameters', "environment=$Environment", "location=$Location",
        '--name', "bicep-demo-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
        '--output', 'json'
    )

    $deploymentStartTime = Get-Date
    Write-ColorOutput "`n🚀 Deployment started at: $($deploymentStartTime.ToString('HH:mm:ss'))`n" -Color $ColorInfo

    $deployment = & az @deployParams 2>&1 | Out-String | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0 -or $deployment.properties.provisioningState -ne 'Succeeded') {
        Write-ErrorMessage "Deployment failed"
        if ($deployment.properties.error) {
            Write-Host ($deployment.properties.error | ConvertTo-Json -Depth 10)
        }
        exit 1
    }

    $deploymentEndTime = Get-Date
    $deploymentDuration = $deploymentEndTime - $deploymentStartTime

    Write-Success "Deployment completed successfully!"
    Write-Host ""
    Write-ColorOutput "⏱️  Deployment Duration: $($deploymentDuration.ToString('mm\:ss'))" -Color $ColorInfo
    Write-Host ""

    # Step 6: Display deployment outputs
    Write-Step "Deployment Outputs:"
    Write-Host ""

    $outputs = $deployment.properties.outputs

    if ($outputs.deploymentSummary) {
        Write-ColorOutput "📊 Deployment Summary:" -Color $ColorInfo
        Write-Host "  Environment: $($outputs.deploymentSummary.value.environment)"
        Write-Host "  Location: $($outputs.deploymentSummary.value.location)"
        Write-Host "  Resource Group: $($outputs.deploymentSummary.value.resourceGroup)"
        Write-Host ""
    }

    if ($outputs.network) {
        Write-ColorOutput "🌐 Network Resources:" -Color $ColorInfo
        Write-Host "  VNet Name: $($outputs.network.value.vnetName)"
        Write-Host "  VNet ID: $($outputs.network.value.vnetId)"
        Write-Host "  Subnets:"
        $outputs.network.value.subnets.PSObject.Properties | ForEach-Object {
            Write-Host "    - $($_.Name): $($_.Value.addressPrefix)"
        }
        Write-Host ""
    }

    if ($outputs.storage) {
        Write-ColorOutput "💾 Storage Resources:" -Color $ColorInfo
        Write-Host "  Storage Account: $($outputs.storage.value.storageAccountName)"
        Write-Host "  Blob Endpoint: $($outputs.storage.value.blobEndpoint)"
        Write-Host "  HTTPS Only: $($outputs.storage.value.properties.httpsOnly)"
        Write-Host "  Min TLS Version: $($outputs.storage.value.properties.minTlsVersion)"
        Write-Host "  Public Access: $($outputs.storage.value.properties.publicAccess)"
        Write-Host ""
    }

    if ($outputs.azurePortalUrls) {
        Write-ColorOutput "🔗 Azure Portal Links:" -Color $ColorInfo
        Write-Host "  Resource Group: $($outputs.azurePortalUrls.value.resourceGroup)"
        Write-Host "  VNet: $($outputs.azurePortalUrls.value.vnet)"
        Write-Host "  Storage: $($outputs.azurePortalUrls.value.storage)"
        Write-Host ""
    }

    if ($outputs.nextSteps) {
        Write-ColorOutput "📝 Next Steps:" -Color $ColorInfo
        $outputs.nextSteps.value | ForEach-Object {
            Write-Host "  • $_"
        }
        Write-Host ""
    }

    # Step 7: Summary
    Write-ColorOutput @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║    ✅ Deployment Successful!                                   ║
║                                                                ║
║    Resources deployed:                                         ║
║    • Virtual Network with 3 subnets                            ║
║    • Network Security Groups (3)                               ║
║    • Storage Account with secure configuration                 ║
║                                                                ║
║    To verify deployment:                                       ║
║    .\verify.ps1 -ResourceGroupName "$ResourceGroupName"       ║
║                                                                ║
║    To clean up:                                                ║
║    .\cleanup.ps1 -ResourceGroupName "$ResourceGroupName"      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@ -Color $ColorSuccess

}
catch {
    Write-ErrorMessage "An unexpected error occurred:"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
    exit 1
}

#endregion

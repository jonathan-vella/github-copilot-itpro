# deploy.ps1 - Deploy Azure Infrastructure
# Purpose: Deploys the Contoso Task Manager infrastructure to Azure
# Usage: .\deploy.ps1 -ResourceGroupName "rg-taskmanager-prod" -Location "eastus"

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('eastus', 'westus', 'centralus', 'northeurope', 'westeurope', 'southeastasia')]
    [string]$Location = 'eastus',
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'staging', 'prod')]
    [string]$Environment = 'prod',
    
    [Parameter(Mandatory = $false)]
    [string]$AdminUsername = 'azureadmin',
    
    [Parameter(Mandatory = $false)]
    [securestring]$AdminPassword,
    
    [Parameter(Mandatory = $false)]
    [string]$SqlAdminUsername = 'sqladmin',
    
    [Parameter(Mandatory = $false)]
    [securestring]$SqlAdminPassword,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================
# FUNCTIONS
# ============================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n▶️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Test-Prerequisites {
    Write-Step "Checking prerequisites..."
    
    # Check Azure CLI
    try {
        $azVersion = az version --output json | ConvertFrom-Json
        Write-Success "Azure CLI version: $($azVersion.'azure-cli')"
    }
    catch {
        Write-Error "Azure CLI is not installed or not in PATH"
        throw "Please install Azure CLI from https://aka.ms/installazurecli"
    }
    
    # Check Bicep CLI
    try {
        $bicepVersion = bicep --version
        Write-Success "Bicep CLI: $bicepVersion"
    }
    catch {
        Write-Error "Bicep CLI is not installed"
        throw "Please install Bicep CLI: az bicep install"
    }
    
    # Check Azure login
    try {
        $account = az account show --output json | ConvertFrom-Json
        Write-Success "Logged in as: $($account.user.name)"
        Write-Host "   Subscription: $($account.name) ($($account.id))" -ForegroundColor Gray
    }
    catch {
        Write-Error "Not logged in to Azure"
        throw "Please run: az login"
    }
}

function New-SecurePassword {
    param([string]$Purpose)
    
    Write-Host "`n🔐 Password required for: $Purpose" -ForegroundColor Yellow
    Write-Host "   Requirements: 12+ characters, uppercase, lowercase, number, special character" -ForegroundColor Gray
    
    $password = Read-Host "   Enter password" -AsSecureString
    $confirmPassword = Read-Host "   Confirm password" -AsSecureString
    
    # Convert to plain text for comparison
    $bstrPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrPassword)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrPassword)
    
    $bstrConfirm = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)
    $plainConfirm = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrConfirm)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrConfirm)
    
    if ($plainPassword -ne $plainConfirm) {
        throw "Passwords do not match"
    }
    
    if ($plainPassword.Length -lt 12) {
        throw "Password must be at least 12 characters long"
    }
    
    # Validate complexity
    $hasUpper = $plainPassword -cmatch '[A-Z]'
    $hasLower = $plainPassword -cmatch '[a-z]'
    $hasDigit = $plainPassword -match '\d'
    $hasSpecial = $plainPassword -match '[^a-zA-Z0-9]'
    
    if (-not ($hasUpper -and $hasLower -and $hasDigit -and $hasSpecial)) {
        throw "Password must contain uppercase, lowercase, number, and special character"
    }
    
    return $password
}

# ============================================
# MAIN SCRIPT
# ============================================

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$bicepFile = Join-Path $scriptPath "main.bicep"
$parameterFile = Join-Path $scriptPath "parameters\$Environment.bicepparam"

Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   Azure Infrastructure Deployment                             ║
║   Contoso Task Manager - Specialization Audit Demo           ║
╚═══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# Prerequisites check
Test-Prerequisites

# Prompt for passwords if not provided
if (-not $AdminPassword) {
    $AdminPassword = New-SecurePassword -Purpose "VM Administrator"
}

if (-not $SqlAdminPassword) {
    $SqlAdminPassword = New-SecurePassword -Purpose "SQL Administrator"
}

# Display deployment parameters
Write-Step "Deployment Configuration"
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Environment: $Environment" -ForegroundColor White
Write-Host "   Bicep Template: $bicepFile" -ForegroundColor White

# Create resource group
Write-Step "Creating resource group..."
try {
    $rgExists = az group exists --name $ResourceGroupName --output tsv
    
    if ($rgExists -eq 'true') {
        Write-Warning "Resource group '$ResourceGroupName' already exists"
    }
    else {
        az group create --name $ResourceGroupName --location $Location --output none
        Write-Success "Resource group created: $ResourceGroupName"
    }
}
catch {
    Write-Error "Failed to create resource group: $_"
    throw
}

# Validate Bicep template
if (-not $SkipValidation) {
    Write-Step "Validating Bicep template..."
    try {
        bicep build $bicepFile
        Write-Success "Bicep template is valid"
    }
    catch {
        Write-Error "Bicep validation failed: $_"
        throw
    }
}

# What-if analysis
if ($WhatIf) {
    Write-Step "Running what-if analysis..."
    
    $bstrAdminPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword)
    $plainAdminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrAdminPassword)
    
    $bstrSqlPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlAdminPassword)
    $plainSqlPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrSqlPassword)
    
    az deployment group what-if `
        --resource-group $ResourceGroupName `
        --template-file $bicepFile `
        --parameters location=$Location `
        --parameters environment=$Environment `
        --parameters adminUsername=$AdminUsername `
        --parameters adminPassword=$plainAdminPassword `
        --parameters sqlAdminUsername=$SqlAdminUsername `
        --parameters sqlAdminPassword=$plainSqlPassword
    
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrAdminPassword)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrSqlPassword)
    
    Write-Host "`n⚠️  What-if analysis complete. Run without -WhatIf to deploy." -ForegroundColor Yellow
    exit 0
}

# Deploy infrastructure
Write-Step "Deploying infrastructure..."
Write-Host "   This may take 15-20 minutes..." -ForegroundColor Gray

$deploymentName = "taskmanager-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$startTime = Get-Date

try {
    $bstrAdminPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword)
    $plainAdminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrAdminPassword)
    
    $bstrSqlPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlAdminPassword)
    $plainSqlPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrSqlPassword)
    
    $deployment = az deployment group create `
        --name $deploymentName `
        --resource-group $ResourceGroupName `
        --template-file $bicepFile `
        --parameters location=$Location `
        --parameters environment=$Environment `
        --parameters adminUsername=$AdminUsername `
        --parameters adminPassword=$plainAdminPassword `
        --parameters sqlAdminUsername=$SqlAdminUsername `
        --parameters sqlAdminPassword=$plainSqlPassword `
        --output json | ConvertFrom-Json
    
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrAdminPassword)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrSqlPassword)
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Success "Deployment completed successfully!"
    Write-Host "   Duration: $($duration.Minutes) minutes $($duration.Seconds) seconds" -ForegroundColor Gray
    
    # Display outputs
    Write-Step "Deployment Outputs"
    Write-Host "   Application URL: $($deployment.properties.outputs.applicationUrl.value)" -ForegroundColor Green
    Write-Host "   SQL Server: $($deployment.properties.outputs.sqlServerFqdn.value)" -ForegroundColor White
    Write-Host "   Database: $($deployment.properties.outputs.databaseName.value)" -ForegroundColor White
    Write-Host "   VMs: $($deployment.properties.outputs.vmNames.value -join ', ')" -ForegroundColor White
    
    # Save outputs to file
    $outputFile = Join-Path $scriptPath "deployment-output-$Environment.json"
    $deployment.properties.outputs | ConvertTo-Json -Depth 10 | Out-File $outputFile
    Write-Success "Deployment outputs saved to: $outputFile"
    
    Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║   ✅ DEPLOYMENT SUCCESSFUL                                    ║
╚═══════════════════════════════════════════════════════════════╝

Next Steps:
1. Deploy the TaskManager.Web application to the VMs
2. Configure the SQL database schema (run application/database/schema.sql)
3. Update Web.config connection string with SQL credentials
4. Test the application at: $($deployment.properties.outputs.applicationUrl.value)
5. Run validation script: .\scripts\validate.ps1 -ResourceGroupName $ResourceGroupName

"@ -ForegroundColor Green
}
catch {
    Write-Error "Deployment failed: $_"
    Write-Host "`n   Check deployment logs in Azure Portal:" -ForegroundColor Gray
    Write-Host "   https://portal.azure.com/#blade/HubsExtension/DeploymentDetailsBlade/id/%2Fsubscriptions%2F$($account.id)%2FresourceGroups%2F$ResourceGroupName%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F$deploymentName" -ForegroundColor Gray
    throw
}

<#
.SYNOPSIS
    S05 Service Validation Deployment (SAIF Application with Testing Infrastructure)
.DESCRIPTION
    Deploys service validation demo environment with SAIF application for load testing,
    chaos engineering, and UAT automation scenarios. Uses managed identity to Azure SQL.
.PARAMETER location
    Azure region: swedencentral (default) or germanywestcentral
.PARAMETER resourceGroupName
    Optional RG name; default rg-s05-validation-swc01/gwc01
.PARAMETER skipContainers
    Skip container build/push (infra only)
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("swedencentral", "germanywestcentral", "westeurope", "northeurope")]
  [string]$location = "swedencentral",
  [Parameter(Mandatory = $false)]
  [string]$resourceGroupName,
  [Parameter(Mandatory = $false)]
  [switch]$skipContainers,
  [Parameter(Mandatory = $false, HelpMessage = "Skip configuring SQL firewall and DB permissions")]
  [switch]$skipSqlAccessConfig,
  [Parameter(Mandatory = $false, HelpMessage = "Name of the SQL firewall rule for your client IP")]
  [string]$FirewallRuleName = "client-ip",
  [Parameter(Mandatory = $false, HelpMessage = "Database roles to grant to the API Managed Identity user")]
  [string[]]$GrantRoles = @('db_datareader'),
  [Parameter(Mandatory = $false, HelpMessage = "Optional clientId (GUID) of a User-Assigned Managed Identity to use")]
  [string]$UserAssignedClientId,
  [Parameter(Mandatory = $false, HelpMessage = "Optional explicit AAD ObjectId for SQL AAD Admin (bypass auto-resolution)")]
  [ValidatePattern('^[0-9a-fA-F-]{36}$')]
  [string]$aadAdminObjectId
)

function Show-Banner { param([string]$m); $b = "=" * ($m.Length + 4); Write-Host "`n$b" -ForegroundColor Cyan; Write-Host "| $m |" -ForegroundColor White -BackgroundColor DarkBlue; Write-Host $b -ForegroundColor Cyan; Write-Host "" }

Show-Banner "S05 Service Validation Deployment"

try { $acct = az account show --query "{name:name, user:user.name, id:id}" -o json | ConvertFrom-Json } catch { Write-Host "Please run 'az login'" -ForegroundColor Red; exit 1 }
Write-Host "Using subscription: $($acct.name) ($($acct.id))" -ForegroundColor Green

if (-not $resourceGroupName) { 
  $suffix = switch ($location) {
    'swedencentral' { 'swc01' }
    'germanywestcentral' { 'gwc01' }
    'westeurope' { 'weu01' }
    'northeurope' { 'neu01' }
    default { 'swc01' }
  }
  $resourceGroupName = "rg-s05-validation-$suffix"
}

# Tags
$defaultApp = "S05-Service-Validation"
$appInput = Read-Host "Application tag [$defaultApp]"
$applicationName = if ([string]::IsNullOrWhiteSpace($appInput)) { $defaultApp } else { $appInput }
$defaultOwner = $acct.user; if ([string]::IsNullOrWhiteSpace($defaultOwner)) { $defaultOwner = "Unknown" }
$ownerInput = Read-Host "Owner tag [$defaultOwner]"
$owner = if ([string]::IsNullOrWhiteSpace($ownerInput)) { $defaultOwner } else { $ownerInput }
$createdBy = "Bicep"
$lastModified = (Get-Date -Format 'yyyy-MM-dd')
$environmentTag = "demo"
$purposeTag = "Service Validation and Testing Demo"

# Resource Group
$rgExists = az group exists --name $resourceGroupName -o tsv
if ($rgExists -eq "false") {
  Write-Host "Creating RG $resourceGroupName in $location" -ForegroundColor Green
  az group create --name $resourceGroupName --location $location --tags `
    Environment=$environmentTag Application="$applicationName" Owner="$owner" CreatedBy="$createdBy" LastModified="$lastModified" Purpose="$purposeTag" | Out-Null
}
else {
  Write-Host "RG exists: $resourceGroupName" -ForegroundColor Green
  az group update --name $resourceGroupName --tags `
    Environment=$environmentTag Application="$applicationName" Owner="$owner" CreatedBy="$createdBy" LastModified="$lastModified" Purpose="$purposeTag" | Out-Null
}

# SQL admin password prompt (infra requires params though API won't use it)
$sqlPwd = Read-Host "Enter SQL Admin Password (min 12 chars)" -AsSecureString
$BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlPwd)
try {
  $sqlPwdText = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
}
finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
}
if ($sqlPwdText.Length -lt 12) { 
  Write-Host "Password too short (received $($sqlPwdText.Length) chars, need 12+)" -ForegroundColor Red
  exit 1 
}

# AAD Admin inputs (to automate EXTERNAL PROVIDER support)
$aadAdminLogin = Read-Host "AAD Admin Login (UPN or display name) [default: $($acct.user)]"
if ([string]::IsNullOrWhiteSpace($aadAdminLogin)) { $aadAdminLogin = $acct.user }

if ($PSBoundParameters.ContainsKey('aadAdminObjectId')) {
  Write-Host "Using provided AAD ObjectId override: $aadAdminObjectId" -ForegroundColor Yellow
}
else {
  $resolvedObjectId = $null
  # Attempt user lookup
  try { $resolvedObjectId = az ad user show --id $aadAdminLogin --query id -o tsv 2>$null } catch { }
  # Attempt group lookup
  if (-not $resolvedObjectId) { try { $resolvedObjectId = az ad group show --group $aadAdminLogin --query id -o tsv 2>$null } catch { } }
  # Signed-in user fallback
  if (-not $resolvedObjectId) { try { $resolvedObjectId = az ad signed-in-user show --query id -o tsv 2>$null } catch { } }
  # Last resort: Graph direct query (may require additional scopes)
  if (-not $resolvedObjectId) {
    try {
      $graphUserJson = az rest --method GET --url "https://graph.microsoft.com/v1.0/users/$aadAdminLogin" --query id -o tsv 2>$null
      if ($graphUserJson) { $resolvedObjectId = $graphUserJson }
    }
    catch { }
  }
  if (-not $resolvedObjectId) {
    Write-Host "Could not auto-resolve AAD ObjectId for '$aadAdminLogin'." -ForegroundColor Red
    Write-Host "Provide it explicitly with -aadAdminObjectId <GUID> (find via: az ad signed-in-user show --query id -o tsv)" -ForegroundColor Yellow
    exit 1
  }
  $aadAdminObjectId = $resolvedObjectId
}

Show-Banner "Provisioning Infrastructure"
$deployName = "s05-validation-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$infraPath = Join-Path $PSScriptRoot "..\infra\main.bicep"
$state = az deployment group create `
  --resource-group $resourceGroupName `
  --template-file $infraPath `
  --parameters location=$location sqlAdminPassword=$sqlPwdText applicationName="$applicationName" owner="$owner" `
  aadAdminLogin="$aadAdminLogin" aadAdminObjectId="$aadAdminObjectId" `
  --name $deployName `
  --query "properties.provisioningState" -o tsv
if ($state -ne "Succeeded") { Write-Host "Infra deployment failed" -ForegroundColor Red; exit 1 }

$outs = az deployment group show --resource-group $resourceGroupName --name $deployName --query properties.outputs -o json | ConvertFrom-Json
$acrName = $outs.acrName.value
$apiApp = $outs.apiAppServiceName.value
$webApp = $outs.webAppServiceName.value
$sqlServer = $outs.sqlServerName.value
$sqlDb = $outs.sqlDatabaseName.value
$apiUrl = $outs.apiUrl.value

if (-not $skipContainers) {
  Show-Banner "Build & Push Application Containers"
  
  $appPath = Join-Path $PSScriptRoot "..\app"
  Write-Host "Building API container from: $appPath" -ForegroundColor Cyan
  az acr build --registry $acrName --image saifv2/api:latest $appPath
  if ($LASTEXITCODE -ne 0) { Write-Host "API image build failed" -ForegroundColor Red; exit 1 }
  
  $webPath = Join-Path $PSScriptRoot "..\web"
  Write-Host "Building Web container from: $webPath" -ForegroundColor Cyan
  az acr build --registry $acrName --image saif/web:latest $webPath
  if ($LASTEXITCODE -ne 0) { Write-Host "Web image build failed" -ForegroundColor Red; exit 1 }
  
  Write-Host "Restarting App Services" -ForegroundColor Green
  az webapp restart --name $apiApp --resource-group $resourceGroupName | Out-Null
  az webapp restart --name $webApp --resource-group $resourceGroupName | Out-Null
}

if (-not $skipSqlAccessConfig) {
  Show-Banner "Configuring SQL Firewall & DB Access (Managed Identity)"
  $configureScript = Join-Path $PSScriptRoot 'Configure-SqlAccess.ps1'
  if (-not (Test-Path $configureScript)) {
    Write-Host "Configuration script not found: $configureScript" -ForegroundColor Red
  }
  else {
    try {
      $cfgParams = @{
        location          = $location
        ResourceGroupName = $resourceGroupName
        FirewallRuleName  = $FirewallRuleName
        Roles             = $GrantRoles
      }
      # Only pass UserAssignedClientId if a non-empty, valid GUID is provided
      if (-not [string]::IsNullOrWhiteSpace($UserAssignedClientId)) {
        if ($UserAssignedClientId -match '^[0-9a-fA-F-]{36}$') {
          $cfgParams['UserAssignedClientId'] = $UserAssignedClientId
        }
        else {
          Write-Host "Ignoring invalid UserAssignedClientId (not a GUID): $UserAssignedClientId" -ForegroundColor Yellow
        }
      }
      & $configureScript @cfgParams
    }
    catch {
      Write-Host "SQL access configuration failed: $($_.Exception.Message)" -ForegroundColor Red
    }
  }
}
else {
  Write-Host "Skipping SQL access configuration (firewall and DB user/roles)" -ForegroundColor Yellow
}

Show-Banner "S05 Service Validation Deployment Complete"
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Green
Write-Host "API URL: $($outs.apiUrl.value)" -ForegroundColor Green
Write-Host "Web URL: $($outs.webUrl.value)" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run load tests: .\testing\load-testing\Run-LoadTest.ps1" -ForegroundColor Cyan
Write-Host "  2. Execute chaos experiments: .\testing\chaos\Run-ChaosExperiment.ps1" -ForegroundColor Cyan
Write-Host "  3. Perform UAT: .\testing\uat\Run-UATTests.ps1" -ForegroundColor Cyan

# Clear sensitive
$sqlPwdText = $null; $sqlPwd = $null

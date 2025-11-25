<#
.SYNOPSIS
Configures Azure SQL access for SAIF v2: adds a firewall rule for your public IP and grants DB permissions to the API app's managed identity.

.DESCRIPTION
This script:
1) Detects your public IP and adds a SQL server firewall rule to allow access
2) Discovers the API Web App and reads SQL_SERVER/SQL_DATABASE app settings
3) Creates a contained user for the Web App's managed identity in that database
4) Grants db_datareader by default (configurable)

It uses Azure AD token-based auth to run T-SQL with Invoke-Sqlcmd. Requires the SqlServer PowerShell module.

.PARAMETER location
Azure region short name used to derive the default resource group (germanywestcentral|swedencentral). Default: germanywestcentral.

.PARAMETER ResourceGroupName
Resource group that hosts SAIF v2 resources. If omitted, derived from -location: rg-saifv2-gwc01 or rg-saifv2-swc01.

.PARAMETER ApiAppName
Name of the API App Service (Linux). If omitted, the script will autodiscover an app whose name contains '-api-'.

.PARAMETER FirewallRuleName
Name for the SQL firewall rule to create/update. Default: 'client-ip'.

.PARAMETER Roles
Database roles to grant to the managed identity user. Default: 'db_datareader'.

.PARAMETER UserAssignedClientId
Optional Client Id (GUID) of a User-Assigned Managed Identity that the API app uses. If provided, the database user will be created using this identity; otherwise the system-assigned identity of the API app is used.

.PARAMETER WhatIf
Performs a dry run without applying changes.

.EXAMPLE
./Configure-SAIF-SqlAccess.ps1 -location germanywestcentral -ResourceGroupName rg-saifv2-gwc01 -FirewallRuleName "dev-laptop" -Roles db_datareader,db_datawriter

.NOTES
Requires: Azure CLI, SqlServer PowerShell module (auto-installed if missing)

.LINK
https://github.com/jonathan-vella/SAIF
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("germanywestcentral","swedencentral")]
  [string]$location = "germanywestcentral",

  [Parameter(Mandatory=$false)]
  [string]$ResourceGroupName,

  [Parameter(Mandatory=$false)]
  [string]$ApiAppName,

  [Parameter(Mandatory=$false)]
  [string]$FirewallRuleName = "client-ip",

  [Parameter(Mandatory=$false)]
  [string[]]$Roles = @('db_datareader'),

  [Parameter(Mandatory=$false)]
  [ValidatePattern('^[0-9a-fA-F-]{36}$')]
  [string]$UserAssignedClientId
)

function Ensure-AzCli() {
  try { az account show -o none 2>$null } catch { throw "Azure CLI not logged in. Run 'az login' first." }
}

function Ensure-SqlServerModule() {
  if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "Installing SqlServer PowerShell module (CurrentUser)" -ForegroundColor Yellow
    try { Install-Module SqlServer -Scope CurrentUser -Force -ErrorAction Stop } catch { throw "Failed to install SqlServer module: $($_.Exception.Message)" }
  }
  Import-Module SqlServer -ErrorAction Stop | Out-Null
}

function Get-PublicIp() {
  try { return (Invoke-RestMethod -Uri 'https://api.ipify.org').Trim() } catch { throw "Unable to determine public IP: $($_.Exception.Message)" }
}

function Get-ApiApp([string]$rg, [string]$nameHint) {
  $apps = az webapp list -g $rg -o json | ConvertFrom-Json
  if (-not $apps) { throw "No web apps found in resource group '$rg'" }
  if ($nameHint) {
    $app = $apps | Where-Object { $_.name -eq $nameHint } | Select-Object -First 1
    if ($app) { return $app }
    throw "API app '$nameHint' not found in '$rg'"
  }
  $api = $apps | Where-Object { $_.name -match '-api-' } | Select-Object -First 1
  if (-not $api) { $api = $apps | Select-Object -First 1 }
  return $api
}

function Get-AppSqlSettings([string]$rg, [string]$appName) {
  $s = az webapp config appsettings list -g $rg -n $appName -o json | ConvertFrom-Json
  $map = @{}
  foreach ($kv in $s) { $map[$kv.name] = $kv.value }
  $server = $map['SQL_SERVER']
  $db = $map['SQL_DATABASE']
  if (-not $server -or -not $db) { throw "App settings SQL_SERVER/SQL_DATABASE not found on '$appName'" }
  return @{ Server=$server; Database=$db }
}

function Get-SqlServerName([string]$serverSetting) {
  # serverSetting might be like 'myserver.database.windows.net' or 'myserver'
  if ($serverSetting -match '^(?<name>[^\.]+)\.database\.windows\.net$') { return $Matches['name'] }
  return $serverSetting
}

function Add-FirewallRule([string]$rg, [string]$serverName, [string]$ruleName, [string]$ip) {
  Write-Host "Adding/Updating firewall rule '$ruleName' for $ip on server $serverName" -ForegroundColor Cyan
  az sql server firewall-rule create -g $rg -s $serverName -n $ruleName --start-ip-address $ip --end-ip-address $ip -o none
}

function Get-ManagedIdentity([string]$rg, [string]$appName) {
  $id = az webapp identity show -g $rg -n $appName -o json | ConvertFrom-Json
  return $id
}

function Get-AadToken([string]$resource) {
  $tok = az account get-access-token --resource $resource -o json | ConvertFrom-Json
  return $tok.accessToken
}

function Ensure-DbUser([string]$serverFqdn, [string]$db, [string]$principalNameOrGuid, [string]$accessToken, [string[]]$roles) {
  $tsql = @()
  $tsql += "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$principalNameOrGuid')"
  $tsql += "BEGIN"
  $tsql += "  CREATE USER [$principalNameOrGuid] FROM EXTERNAL PROVIDER;"
  $tsql += "END"
  foreach ($r in $roles) { $tsql += "IF IS_MEMBER('$r') = 0 BEGIN ALTER ROLE [$r] ADD MEMBER [$principalNameOrGuid]; END" }
  $query = $tsql -join " `n"

  Write-Host "Creating user and granting roles in DB '$db' for '$principalNameOrGuid'" -ForegroundColor Cyan
  Invoke-Sqlcmd -ServerInstance $serverFqdn -Database $db -AccessToken $accessToken -Query $query -Verbose
}

try {
  Ensure-AzCli
  Ensure-SqlServerModule

  if (-not $ResourceGroupName) { $ResourceGroupName = ($location -eq 'swedencentral') ? 'rg-saifv2-swc01' : 'rg-saifv2-gwc01' }

  $apiApp = Get-ApiApp -rg $ResourceGroupName -nameHint $ApiAppName
  $apiAppName = $apiApp.name
  Write-Host "Using API app: $apiAppName" -ForegroundColor Green

  $sql = Get-AppSqlSettings -rg $ResourceGroupName -appName $apiAppName
  $serverSetting = $sql.Server
  $dbName = $sql.Database
  $serverShort = Get-SqlServerName -serverSetting $serverSetting
  $serverFqdn = "$serverShort.database.windows.net"

  $clientIp = Get-PublicIp
  if ($PSCmdlet.ShouldProcess("SQL Server $serverShort", "Allow client IP $clientIp")) {
    Add-FirewallRule -rg $ResourceGroupName -serverName $serverShort -ruleName $FirewallRuleName -ip $clientIp
  }

  $mi = Get-ManagedIdentity -rg $ResourceGroupName -appName $apiAppName
  $principalDisplayName = $apiAppName
  $principalNameOrGuid = if ($UserAssignedClientId) { $UserAssignedClientId } else { $principalDisplayName }

  $aadToken = Get-AadToken -resource "https://database.windows.net/"
  if ($PSCmdlet.ShouldProcess("DB $dbName@$serverFqdn", "Create user and grant roles to '$principalNameOrGuid'")) {
    Ensure-DbUser -serverFqdn $serverFqdn -db $dbName -principalNameOrGuid $principalNameOrGuid -accessToken $aadToken -roles $Roles
  }

  Write-Host "Done. Validate via /api/sqlwhoami and /api/sqlversion." -ForegroundColor Green
}
catch {
  Write-Error $_
  exit 1
}

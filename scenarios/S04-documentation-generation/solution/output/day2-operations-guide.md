# Day 2 Operations Guide - Contoso Patient Portal

**Resource Group**: `rg-contoso-patient-portal-dev`  
**Environment**: Development  
**Region**: Sweden Central  
**Generated**: November 20, 2025  
**Last Updated**: November 20, 2025

---

## 1. Daily Operations Checklist

**Time Estimate**: 15-20 minutes  
**Frequency**: Every business day morning (8:00 AM local time)

| Task | Resource | Time | Priority |
|------|----------|------|----------|
| ✅ Check App Service health status | `app-contosopat-dev-qkfwso` | 2 min | Critical |
| ✅ Verify SQL Database connectivity | `sqldb-patients-dev-qkfwso` | 2 min | Critical |
| ✅ Review Application Insights errors (last 24h) | `appi-contosopa-dev-qkfwso` | 5 min | High |
| ✅ Check Log Analytics workspace health | `log-contosopat-dev-qkfwso` | 2 min | Medium |
| ✅ Verify Key Vault access logs | `kv-contosop-dev-qkfwso` | 3 min | High |
| ✅ Review NSG flow logs for anomalies | `nsg-web-dev-qkfwso`, `nsg-data-dev-qkfwso` | 3 min | Medium |
| ✅ Check daily cost (vs. budget) | All resources | 3 min | Medium |

**Automation Script** (Daily Health Check):

```powershell
# Daily-HealthCheck.ps1
param(
    [string]$ResourceGroupName = "rg-contoso-patient-portal-dev",
    [string]$AppServiceName = "app-contosopat-dev-qkfwso",
    [string]$SqlServerName = "sql-contosopat-dev-qkfwso",
    [string]$AppInsightsName = "appi-contosopa-dev-qkfwso"
)

$results = @()

# 1. Check App Service health
Write-Host "Checking App Service health..." -ForegroundColor Cyan
$appService = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName
$appHealth = if ($appService.State -eq "Running") { "✅ Healthy" } else { "❌ Unhealthy - State: $($appService.State)" }
$results += "App Service: $appHealth"

# 2. Test SQL Database connectivity
Write-Host "Testing SQL Database connectivity..." -ForegroundColor Cyan
$sqlServer = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName
$sqlHealth = if ($sqlServer.State -eq "Ready") { "✅ Healthy" } else { "❌ Unhealthy - State: $($sqlServer.State)" }
$results += "SQL Server: $sqlHealth"

# 3. Check Application Insights errors (last 24 hours)
Write-Host "Querying Application Insights for errors..." -ForegroundColor Cyan
$query = @"
exceptions
| where timestamp > ago(24h)
| summarize ErrorCount = count()
"@

try {
    $appInsights = Get-AzApplicationInsights -ResourceGroupName $ResourceGroupName -Name $AppInsightsName
    $queryResult = Invoke-AzOperationalInsightsQuery -WorkspaceId $appInsights.AppId -Query $query -ErrorAction SilentlyContinue
    $errorCount = if ($queryResult.Results) { $queryResult.Results[0].ErrorCount } else { 0 }
    $errorHealth = if ($errorCount -lt 10) { "✅ Normal ($errorCount errors)" } else { "⚠️ Elevated ($errorCount errors)" }
    $results += "Application Insights: $errorHealth"
} catch {
    $results += "Application Insights: ⚠️ Unable to query (check permissions)"
}

# 4. Check today's cost
Write-Host "Checking daily cost..." -ForegroundColor Cyan
$today = Get-Date -Format "yyyy-MM-dd"
$cost = (Get-AzConsumptionUsageDetail -StartDate $today -EndDate $today -ResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue | 
    Measure-Object -Property PretaxCost -Sum).Sum
$costHealth = if ($cost -lt 50) { "✅ On budget (\$$($cost.ToString('0.00')))" } else { "⚠️ High (\$$($cost.ToString('0.00')))" }
$results += "Daily Cost: $costHealth"

# Summary report
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Daily Health Check Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
$results | ForEach-Object { Write-Host $_ }
Write-Host "`nCompleted: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
```

---

## 2. Weekly Maintenance Tasks

**Time Estimate**: 45-60 minutes  
**Frequency**: Every Monday at 10:00 AM

### Week 1 Tasks

| Task | Resource | Duration | Owner |
|------|----------|----------|-------|
| Verify automatic SQL backups | `sqldb-patients-dev-qkfwso` | 10 min | DBA |
| Review App Service logs for warnings | `app-contosopat-dev-qkfwso` | 15 min | DevOps |
| Check Key Vault access policies | `kv-contosop-dev-qkfwso` | 10 min | SecOps |
| Review NSG rules for changes | `nsg-web-dev-qkfwso`, `nsg-data-dev-qkfwso` | 10 min | NetOps |
| Analyze Application Insights performance trends | `appi-contosopa-dev-qkfwso` | 15 min | DevOps |

### Backup Verification Script

```powershell
# Weekly-BackupVerification.ps1
param(
    [string]$ResourceGroupName = "rg-contoso-patient-portal-dev",
    [string]$SqlServerName = "sql-contosopat-dev-qkfwso",
    [string]$DatabaseName = "sqldb-patients-dev-qkfwso"
)

Write-Host "Verifying SQL Database backups..." -ForegroundColor Cyan

# Get recent backups
$backups = Get-AzSqlDatabaseRestorePoint -ResourceGroupName $ResourceGroupName `
    -ServerName $SqlServerName -DatabaseName $DatabaseName

Write-Host "`nAvailable Restore Points:" -ForegroundColor Green
$backups | Select-Object -First 7 | Format-Table RestorePointType, RestorePointCreationDate, EarliestRestoreDate

# Check latest backup age
$latestBackup = $backups | Sort-Object RestorePointCreationDate -Descending | Select-Object -First 1
$backupAge = (Get-Date) - $latestBackup.RestorePointCreationDate

if ($backupAge.TotalHours -lt 24) {
    Write-Host "✅ Latest backup is recent ($($backupAge.Hours) hours old)" -ForegroundColor Green
} else {
    Write-Host "⚠️ Latest backup is older than 24 hours ($($backupAge.Days) days old)" -ForegroundColor Yellow
}

# Verify point-in-time restore capability
if ($backups.RestorePointType -contains "CONTINUOUS") {
    Write-Host "✅ Point-in-time restore is enabled" -ForegroundColor Green
} else {
    Write-Host "❌ Point-in-time restore is NOT enabled!" -ForegroundColor Red
}
```

---

## 3. Monthly Operations

**Time Estimate**: 2-3 hours  
**Frequency**: First Monday of each month

### Capacity Planning Review

```powershell
# Monthly-CapacityReview.ps1
param(
    [string]$ResourceGroupName = "rg-contoso-patient-portal-dev"
)

Write-Host "Generating monthly capacity report..." -ForegroundColor Cyan

# App Service Plan metrics
$aspName = "asp-contosopat-dev-qkfwso"
$asp = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $aspName

Write-Host "`n=== App Service Plan ===" -ForegroundColor Green
Write-Host "SKU: $($asp.Sku.Name) ($($asp.Sku.Tier))"
Write-Host "Instances: $($asp.Sku.Capacity)"
Write-Host "Current Apps: $($asp.NumberOfSites)"

# Check CPU/Memory trends (last 30 days)
$query = @"
AzureMetrics
| where ResourceId contains 'asp-contosopat-dev-qkfwso'
| where TimeGenerated > ago(30d)
| where MetricName in ('CpuPercentage', 'MemoryPercentage')
| summarize 
    AvgCPU = avg(iif(MetricName == 'CpuPercentage', Average, real(null))),
    P95CPU = percentile(iif(MetricName == 'CpuPercentage', Average, real(null)), 95),
    AvgMemory = avg(iif(MetricName == 'MemoryPercentage', Average, real(null))),
    P95Memory = percentile(iif(MetricName == 'MemoryPercentage', Average, real(null)), 95)
"@

Write-Host "`nPerformance Metrics (Last 30 Days):"
Write-Host "Run this KQL query in Log Analytics for detailed analysis"

# SQL Database DTU usage
$sqlServerName = "sql-contosopat-dev-qkfwso"
$dbName = "sqldb-patients-dev-qkfwso"
$db = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $sqlServerName -DatabaseName $dbName

Write-Host "`n=== SQL Database ===" -ForegroundColor Green
Write-Host "Edition: $($db.Edition)"
Write-Host "Service Objective: $($db.CurrentServiceObjectiveName)"
Write-Host "Max Size: $($db.MaxSizeBytes / 1GB) GB"

# Scaling recommendations
Write-Host "`n=== Scaling Recommendations ===" -ForegroundColor Yellow
Write-Host "1. If CPU > 70% consistently → Consider upgrading App Service Plan"
Write-Host "2. If Memory > 80% consistently → Add more instances or upgrade tier"
Write-Host "3. If SQL DTU > 80% → Consider upgrading to higher tier or elastic pool"
Write-Host "4. If storage > 80% → Increase database max size"
```

### Cost Optimization Review

| Resource Type | Current SKU | Monthly Cost | Optimization Opportunity | Savings |
|--------------|-------------|--------------|--------------------------|---------|
| App Service Plan | P1v3 (Premium) | ~$140 | Consider B2 for dev environment | ~$90/mo |
| SQL Database | Standard S2 | ~$150 | Use S1 for dev workload | ~$90/mo |
| Log Analytics | Pay-as-you-go | ~$50 | Set data retention to 30 days | ~$20/mo |
| **Total** | | **~$340** | **Potential Savings** | **~$200/mo** |

---

## 4. Monitoring & Alerting Setup

### App Service (`app-contosopat-dev-qkfwso`)

**Critical Metrics:**

- **CPU Percentage**: Alert when >80% for 5+ minutes
- **Memory Percentage**: Alert when >85% for 5+ minutes
- **HTTP 5xx Errors**: Alert when >10 errors in 5 minutes
- **Response Time (P95)**: Alert when >3 seconds
- **Availability**: Alert when <99.9% over 5 minutes

**Azure Monitor Query (CPU Threshold)**:

```kql
AzureMetrics
| where ResourceId contains "app-contosopat-dev-qkfwso"
| where MetricName == "CpuPercentage"
| where TimeGenerated > ago(1h)
| summarize AvgCPU = avg(Average) by bin(TimeGenerated, 5m)
| where AvgCPU > 80
| project TimeGenerated, AvgCPU
| order by TimeGenerated desc
```

**Alert Configuration (Azure CLI)**:

```bash
# Create CPU alert
az monitor metrics alert create \
  --name "AppService-HighCPU" \
  --resource-group rg-contoso-patient-portal-dev \
  --scopes /subscriptions/{sub-id}/resourceGroups/rg-contoso-patient-portal-dev/providers/Microsoft.Web/sites/app-contosopat-dev-qkfwso \
  --condition "avg CpuPercentage > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action-group {action-group-id} \
  --description "App Service CPU exceeds 80% for 5 minutes"
```

### SQL Database (`sqldb-patients-dev-qkfwso`)

**Critical Metrics:**

- **DTU Percentage**: Alert when >80% for 10 minutes
- **Connection Failed**: Alert when >5 failures in 5 minutes
- **Blocked by Firewall**: Alert on any occurrence
- **Deadlocks**: Alert when >2 deadlocks in 1 hour
- **Storage Percentage**: Alert when >85%

**KQL Query (Connection Failures)**:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where Category == "Errors"
| where TimeGenerated > ago(1h)
| summarize FailureCount = count() by bin(TimeGenerated, 5m), ErrorMessage = Message
| where FailureCount > 5
```

### Key Vault (`kv-contosop-dev-qkfwso`)

**Critical Metrics:**

- **Service API Latency**: Alert when P95 >1000ms
- **Failed Requests**: Alert when >5 failures in 5 minutes
- **Availability**: Alert when <99.9%
- **Vault Capacity**: Alert when >80% (near 25K transactions/10s limit)

**KQL Query (Failed Access Attempts)**:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where ResultSignature != "OK"
| where TimeGenerated > ago(1h)
| summarize FailureCount = count() by bin(TimeGenerated, 5m), CallerIPAddress, identity_claim_http_schemas_xmlsoap_org_ws_2005_05_identity_claims_upn_s
| where FailureCount > 5
| order by TimeGenerated desc
```

### Application Insights (`appi-contosopa-dev-qkfwso`)

**Critical Metrics:**

- **Exception Rate**: Alert when >10 exceptions per minute
- **Failed Requests**: Alert when >5% failure rate
- **Dependency Duration**: Alert when P95 >2 seconds
- **Page Load Time**: Alert when P95 >5 seconds

**KQL Query (Exception Trends)**:

```kql
exceptions
| where timestamp > ago(24h)
| summarize ExceptionCount = count() by bin(timestamp, 15m), type
| order by timestamp desc
| render timechart
```

### Network Security Groups

**Monitoring Focus:**

- **Denied Flows**: Alert on unusual spike (>100 denied connections in 5 minutes)
- **Allowed Flows from Unknown IPs**: Alert on connections from non-whitelisted IPs
- **Port Scanning Activity**: Alert on sequential port access attempts

**KQL Query (NSG Denied Flows)**:

```kql
AzureDiagnostics
| where ResourceType == "NETWORKSECURITYGROUPS"
| where FlowStatus_s == "D"  // Denied
| where TimeGenerated > ago(1h)
| summarize DeniedCount = count() by bin(TimeGenerated, 5m), SourceIP_s, DestinationPort_d, NSGRule_s
| where DeniedCount > 100
| order by TimeGenerated desc
```

---

## 5. Backup & Recovery Procedures

### SQL Database Backup Strategy

**Automatic Backups (Managed by Azure)**:

- **Full Backup**: Weekly (Sunday midnight)
- **Differential Backup**: Every 12-24 hours
- **Transaction Log Backup**: Every 5-10 minutes
- **Retention**: 7 days (Standard tier default)
- **RPO**: <10 minutes (point-in-time restore)
- **RTO**: <1 hour for database restore

**Manual Backup Procedure**:

```powershell
# Create on-demand database backup
$resourceGroupName = "rg-contoso-patient-portal-dev"
$sqlServerName = "sql-contosopat-dev-qkfwso"
$databaseName = "sqldb-patients-dev-qkfwso"
$storageAccountName = "stcontosopdevqkfwso"  # Create if needed
$containerName = "sqlbackups"
$backupName = "manual-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').bacpac"

# Export database to blob storage
$exportRequest = New-AzSqlDatabaseExport `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value `
    -StorageUri "https://$storageAccountName.blob.core.windows.net/$containerName/$backupName" `
    -AdministratorLogin "sqladmin" `
    -AdministratorLoginPassword (ConvertTo-SecureString "YourPassword" -AsPlainText -Force)

Write-Host "Export initiated. Operation ID: $($exportRequest.OperationStatusLink)"
```

**Recovery Procedure (Point-in-Time Restore)**:

```powershell
# Restore database to specific point in time
$resourceGroupName = "rg-contoso-patient-portal-dev"
$sqlServerName = "sql-contosopat-dev-qkfwso"
$sourceDatabaseName = "sqldb-patients-dev-qkfwso"
$restoredDatabaseName = "sqldb-patients-restored"
$restorePointInTime = (Get-Date).AddHours(-2)  # Restore to 2 hours ago

Restore-AzSqlDatabase `
    -FromPointInTimeBackup `
    -PointInTime $restorePointInTime `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -TargetDatabaseName $restoredDatabaseName `
    -ResourceId (Get-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $sourceDatabaseName).ResourceId

Write-Host "Database restore initiated. Restored database: $restoredDatabaseName"
Write-Host "Verify data, then rename/swap databases as needed."
```

### Key Vault Backup Strategy

**Secrets Backup**:

- **Frequency**: Weekly automated backup
- **Retention**: 90 days (soft-delete enabled)
- **Recovery**: Soft-deleted secrets recoverable for 90 days

**Backup Script**:

```powershell
# Backup all Key Vault secrets
$vaultName = "kv-contosop-dev-qkfwso"
$backupPath = "./keyvault-backups"
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

$secrets = Get-AzKeyVaultSecret -VaultName $vaultName
foreach ($secret in $secrets) {
    $secretName = $secret.Name
    $backupFile = Join-Path $backupPath "$secretName-$(Get-Date -Format 'yyyyMMdd').txt"
    
    Backup-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -OutputFile $backupFile
    Write-Host "✅ Backed up secret: $secretName"
}

Write-Host "`nBackup completed. Files saved to: $backupPath"
```

### App Service Backup

**Configuration Backup**:

- **App Settings**: Export via Azure CLI weekly
- **Deployment Slots**: Not configured in dev (production only)
- **RTO**: <30 minutes (redeploy from source control)
- **RPO**: Source control commit frequency (typically <1 hour)

**Backup Script**:

```bash
# Export App Service configuration
az webapp config appsettings list \
  --name app-contosopat-dev-qkfwso \
  --resource-group rg-contoso-patient-portal-dev \
  --output json > app-settings-backup-$(date +%Y%m%d).json

az webapp config connection-string list \
  --name app-contosopat-dev-qkfwso \
  --resource-group rg-contoso-patient-portal-dev \
  --output json > connection-strings-backup-$(date +%Y%m%d).json
```

---

## 6. Scaling Procedures

### App Service Plan Scaling

**Current Configuration**:
- **SKU**: P1v3 (Premium V3)
- **vCPU**: 2 cores
- **RAM**: 8 GB
- **Storage**: 250 GB
- **Instances**: 1 (manual scaling)
- **Zone Redundancy**: Enabled

**Scale-Up Triggers**:
- CPU >70% for 15+ minutes
- Memory >80% for 15+ minutes
- Response time P95 >3 seconds consistently
- Queue depth growing (if using background jobs)

**Scale-Up Procedure**:

```powershell
# Option 1: Scale up to P2v3 (4 vCPU, 16 GB RAM)
$resourceGroupName = "rg-contoso-patient-portal-dev"
$appServicePlanName = "asp-contosopat-dev-qkfwso"

Set-AzAppServicePlan `
    -ResourceGroupName $resourceGroupName `
    -Name $appServicePlanName `
    -Tier "PremiumV3" `
    -WorkerSize "Medium"  # P2v3

Write-Host "✅ Scaled up to P2v3. Monitor performance for 15 minutes."
```

**Scale-Out Procedure** (Add Instances):

```powershell
# Add instances for horizontal scaling
Set-AzAppServicePlan `
    -ResourceGroupName $resourceGroupName `
    -Name $appServicePlanName `
    -NumberofWorkers 3  # Scale to 3 instances

Write-Host "✅ Scaled out to 3 instances."
```

**Cost Impact**:
| Tier | vCPU | RAM | Instances | Monthly Cost | Use Case |
|------|------|-----|-----------|--------------|----------|
| P1v3 | 2 | 8 GB | 1 | ~$140 | Current (dev) |
| P1v3 | 2 | 8 GB | 3 | ~$420 | High availability |
| P2v3 | 4 | 16 GB | 1 | ~$280 | CPU-intensive workloads |
| P3v3 | 8 | 32 GB | 1 | ~$560 | Memory-intensive workloads |

### SQL Database Scaling

**Current Configuration**:
- **Tier**: Standard
- **Service Level**: S2
- **DTUs**: 50
- **Max Size**: 250 GB

**Scale-Up Triggers**:
- DTU usage >75% for 15+ minutes
- High query wait times
- Storage >80% of max size
- Connection pool exhaustion

**Scale-Up Procedure**:

```powershell
# Scale up SQL Database
$resourceGroupName = "rg-contoso-patient-portal-dev"
$sqlServerName = "sql-contosopat-dev-qkfwso"
$databaseName = "sqldb-patients-dev-qkfwso"

# Scale to S3 (100 DTUs)
Set-AzSqlDatabase `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -Edition "Standard" `
    -RequestedServiceObjectiveName "S3"

Write-Host "✅ Scaled to S3 (100 DTUs). Monitor DTU usage."
```

**Cost Impact**:
| Tier | DTUs | Storage | Monthly Cost | Use Case |
|------|------|---------|--------------|----------|
| S1 | 20 | 250 GB | ~$30 | Light dev workload |
| S2 | 50 | 250 GB | ~$75 | Current (dev) |
| S3 | 100 | 250 GB | ~$150 | Heavy dev workload |
| P1 | 125 | 500 GB | ~$465 | Production |

---

## 7. Security Operations

### Access Review Schedule

**Monthly Review Tasks**:

1. **Key Vault Access Policies**:
```powershell
# List all Key Vault access policies
Get-AzKeyVault -VaultName "kv-contosop-dev-qkfwso" | 
    Select-Object -ExpandProperty AccessPolicies |
    Format-Table ObjectId, DisplayName, PermissionsToSecrets, PermissionsToKeys
```

2. **SQL Server Entra ID Admins**:
```powershell
# Review SQL Server administrators
Get-AzSqlServerActiveDirectoryAdministrator `
    -ResourceGroupName "rg-contoso-patient-portal-dev" `
    -ServerName "sql-contosopat-dev-qkfwso"
```

3. **App Service Authentication**:
```bash
# Review App Service authentication settings
az webapp auth show \
  --name app-contosopat-dev-qkfwso \
  --resource-group rg-contoso-patient-portal-dev
```

### Key Rotation Schedule

**Quarterly Rotation**:

| Secret/Key Type | Location | Rotation Frequency | Next Rotation |
|----------------|----------|-------------------|---------------|
| SQL Connection String | Key Vault | Quarterly | 2026-02-20 |
| App Service Client Secret | Key Vault | Quarterly | 2026-02-20 |
| Storage Account Keys | Key Vault | Quarterly | 2026-02-20 |
| Certificate (if any) | Key Vault | Yearly | 2026-11-20 |

**Key Rotation Script**:

```powershell
# Rotate SQL Server password and update Key Vault
$resourceGroupName = "rg-contoso-patient-portal-dev"
$sqlServerName = "sql-contosopat-dev-qkfwso"
$vaultName = "kv-contosop-dev-qkfwso"
$secretName = "SqlConnectionString"

# Generate new password
$newPassword = -join ((65..90) + (97..122) + (48..57) + (33..47) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$securePassword = ConvertTo-SecureString $newPassword -AsPlainText -Force

# Update SQL Server password (requires Azure AD authentication)
Write-Host "⚠️ Update SQL Server password via Azure Portal or Azure AD authentication"

# Update connection string in Key Vault
$newConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Database=sqldb-patients-dev-qkfwso;User ID=sqladmin;Password=$newPassword;Encrypt=true;Connection Timeout=30;"
$secureConnectionString = ConvertTo-SecureString $newConnectionString -AsPlainText -Force

Set-AzKeyVaultSecret `
    -VaultName $vaultName `
    -Name $secretName `
    -SecretValue $secureConnectionString

Write-Host "✅ Connection string updated in Key Vault"
Write-Host "⚠️ Restart App Service to pick up new connection string"
```

### Network Security Audit

**NSG Rule Review** (Monthly):

```powershell
# Export NSG rules for review
$nsgNames = @("nsg-web-dev-qkfwso", "nsg-data-dev-qkfwso")

foreach ($nsgName in $nsgNames) {
    $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName "rg-contoso-patient-portal-dev"
    
    Write-Host "`n=== $nsgName ===" -ForegroundColor Cyan
    Write-Host "Inbound Rules:"
    $nsg.SecurityRules | Where-Object {$_.Direction -eq "Inbound"} | 
        Format-Table Name, Priority, Access, SourceAddressPrefix, DestinationPortRange
    
    Write-Host "Outbound Rules:"
    $nsg.SecurityRules | Where-Object {$_.Direction -eq "Outbound"} | 
        Format-Table Name, Priority, Access, DestinationAddressPrefix, DestinationPortRange
}
```

**Private Endpoint Verification**:

```powershell
# Verify private endpoints are connected
$privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName "rg-contoso-patient-portal-dev"

foreach ($pe in $privateEndpoints) {
    Write-Host "`n=== $($pe.Name) ===" -ForegroundColor Green
    Write-Host "Connection State: $($pe.PrivateLinkServiceConnections[0].PrivateLinkServiceConnectionState.Status)"
    Write-Host "Private IP: $($pe.NetworkInterfaces[0].IpConfigurations[0].PrivateIpAddress)"
}
```

---

## 8. Cost Management

### Current Monthly Cost Breakdown

| Resource | Type | SKU/Tier | Est. Monthly Cost |
|----------|------|----------|-------------------|
| App Service Plan | Compute | P1v3 | $140 |
| SQL Database | Data | Standard S2 | $75 |
| Application Insights | Monitoring | Pay-as-you-go | $30 |
| Log Analytics Workspace | Monitoring | Pay-as-you-go | $25 |
| Key Vault | Security | Standard | $5 |
| Virtual Network | Network | Standard | $10 |
| Private Endpoints (2) | Network | Standard | $20 |
| NSGs (2) | Network | Free | $0 |
| **Total** | | | **~$305/month** |

### Cost Optimization Opportunities

**Immediate Actions**:

1. **Downsize for Dev** (~$150/month savings):
   - App Service Plan: P1v3 → B2 Basic (~$90 savings)
   - SQL Database: S2 → S1 (~$45 savings)
   - Log Analytics: Set 30-day retention (~$15 savings)

2. **Enable Reserved Instances** (Production only):
   - 1-year reservation: 38% savings
   - 3-year reservation: 55% savings

3. **Auto-Shutdown Schedule** (Dev environment):
   ```powershell
   # Schedule App Service to stop at 6 PM, start at 8 AM weekdays
   # Note: This would require Azure Automation or Logic App
   ```

**Budget Alert Configuration**:

```bash
# Create monthly budget alert at $400
az consumption budget create \
  --budget-name "dev-environment-monthly" \
  --amount 400 \
  --category Cost \
  --time-grain Monthly \
  --start-date 2025-11-01 \
  --end-date 2026-12-31 \
  --resource-group rg-contoso-patient-portal-dev \
  --notifications \
    'threshold=80' 'operator=GreaterThan' 'contactEmails=ops-team@contoso.com' \
    'threshold=100' 'operator=GreaterThan' 'contactEmails=ops-team@contoso.com'
```

### Cost Tracking Tags

**Required Tags**:
```powershell
# Apply cost tracking tags
$tags = @{
    "Environment" = "Development"
    "Project" = "PatientPortal"
    "CostCenter" = "IT-Operations"
    "Owner" = "ops-team@contoso.com"
    "ExpirationDate" = "2026-12-31"
}

$resources = Get-AzResource -ResourceGroupName "rg-contoso-patient-portal-dev"
foreach ($resource in $resources) {
    Set-AzResource -ResourceId $resource.ResourceId -Tag $tags -Force
}
```

---

## 9. Troubleshooting Playbooks

### Issue #1: App Service High CPU Usage

**Symptoms**:
- CPU >80% sustained
- Slow response times (>5 seconds)
- Timeout errors in Application Insights

**Diagnostic Steps**:

1. **Check CPU metrics**:
```kql
AzureMetrics
| where ResourceId contains "app-contosopat-dev-qkfwso"
| where MetricName == "CpuPercentage"
| where TimeGenerated > ago(1h)
| summarize AvgCPU = avg(Average), MaxCPU = max(Maximum) by bin(TimeGenerated, 1m)
| render timechart
```

2. **Identify slow requests**:
```kql
requests
| where timestamp > ago(1h)
| where duration > 3000  // >3 seconds
| summarize Count = count(), AvgDuration = avg(duration) by name, resultCode
| order by AvgDuration desc
```

3. **Check for exceptions**:
```kql
exceptions
| where timestamp > ago(1h)
| summarize Count = count() by type, outerMessage
| order by Count desc
```

**Resolution**:

1. **Immediate**: Scale out App Service Plan (add 1-2 instances)
```powershell
Set-AzAppServicePlan -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "asp-contosopat-dev-qkfwso" -NumberofWorkers 2
```

2. **Short-term**: Identify and optimize slow endpoints
3. **Long-term**: Implement caching, optimize database queries, consider async processing

**Prevention**:
- Set up auto-scaling rules
- Implement query caching
- Add Application Insights profiling

---

### Issue #2: SQL Database Connection Failures

**Symptoms**:
- "Cannot open database" errors
- Connection timeout errors
- App Service logs show SQL exceptions

**Diagnostic Steps**:

1. **Check SQL Server status**:
```powershell
Get-AzSqlServer -ResourceGroupName "rg-contoso-patient-portal-dev" -ServerName "sql-contosopat-dev-qkfwso"
```

2. **Review firewall rules**:
```powershell
Get-AzSqlServerFirewallRule -ResourceGroupName "rg-contoso-patient-portal-dev" -ServerName "sql-contosopat-dev-qkfwso"
```

3. **Test private endpoint connectivity**:
```powershell
Test-NetConnection -ComputerName sql-contosopat-dev-qkfwso.database.windows.net -Port 1433
```

4. **Check for blocked connections**:
```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where Category == "Blocks"
| where TimeGenerated > ago(1h)
| project TimeGenerated, blocked_process_report_s
```

**Resolution**:

1. **Firewall Issue**: Add App Service outbound IPs to SQL firewall
```powershell
# Get App Service outbound IPs
$app = Get-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"
$app.OutboundIpAddresses -split ',' | ForEach-Object {
    New-AzSqlServerFirewallRule `
        -ResourceGroupName "rg-contoso-patient-portal-dev" `
        -ServerName "sql-contosopat-dev-qkfwso" `
        -FirewallRuleName "AllowAppService-$_" `
        -StartIpAddress $_ `
        -EndIpAddress $_
}
```

2. **Connection Pool Exhaustion**: Restart App Service
```powershell
Restart-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"
```

3. **DTU Limit Reached**: Scale up SQL Database tier

**Prevention**:
- Use private endpoint (already configured)
- Implement connection retry logic with exponential backoff
- Monitor DTU usage and set alerts

---

### Issue #3: Key Vault Access Denied

**Symptoms**:
- App Service logs show "403 Forbidden" from Key Vault
- Secrets not loading at startup
- Authentication errors

**Diagnostic Steps**:

1. **Verify App Service managed identity**:
```powershell
$app = Get-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"
$app.Identity
```

2. **Check Key Vault access policies**:
```powershell
Get-AzKeyVault -VaultName "kv-contosop-dev-qkfwso" | Select-Object -ExpandProperty AccessPolicies
```

3. **Review Key Vault diagnostic logs**:
```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where ResultSignature == "Forbidden"
| where TimeGenerated > ago(1h)
| project TimeGenerated, CallerIPAddress, identity_claim_http_schemas_xmlsoap_org_ws_2005_05_identity_claims_upn_s, OperationName
```

**Resolution**:

1. **Grant Key Vault access to App Service managed identity**:
```powershell
$app = Get-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"
$principalId = $app.Identity.PrincipalId

Set-AzKeyVaultAccessPolicy `
    -VaultName "kv-contosop-dev-qkfwso" `
    -ObjectId $principalId `
    -PermissionsToSecrets Get,List
```

2. **Verify private endpoint connection**:
```powershell
Get-AzPrivateEndpoint -Name "pe-keyvault-dev-qkfwso" -ResourceGroupName "rg-contoso-patient-portal-dev"
```

**Prevention**:
- Document access policy requirements in infrastructure-as-code
- Set up alerts for Key Vault 403 errors
- Use Azure RBAC for Key Vault (modern approach)

---

## 10. Automation Opportunities

### Recommended Automation Scripts

**1. Nightly Database Statistics Update**

```powershell
# Update-DatabaseStatistics.ps1
# Schedule: Daily at 2:00 AM via Azure Automation

$resourceGroupName = "rg-contoso-patient-portal-dev"
$sqlServerName = "sql-contosopat-dev-qkfwso"
$databaseName = "sqldb-patients-dev-qkfwso"

# Update statistics for better query performance
$query = @"
EXEC sp_updatestats;
EXEC sp_MSforeachtable 'UPDATE STATISTICS ? WITH FULLSCAN';
"@

# Execute via Azure Automation with SQL connection
Invoke-Sqlcmd -ServerInstance "$sqlServerName.database.windows.net" `
    -Database $databaseName `
    -Query $query `
    -Username "sqladmin" `
    -Password (Get-AutomationVariable -Name 'SqlAdminPassword')

Write-Output "✅ Database statistics updated"
```

**2. Weekly Log Analytics Cleanup**

```powershell
# Cleanup-LogAnalytics.ps1
# Schedule: Weekly on Sunday at 1:00 AM

$workspaceName = "log-contosopat-dev-qkfwso"
$resourceGroupName = "rg-contoso-patient-portal-dev"

# Purge old data (>60 days) to reduce costs
$purgeId = Invoke-AzOperationalInsightsQuery `
    -WorkspaceId (Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $resourceGroupName).CustomerId `
    -Query "Heartbeat | where TimeGenerated < ago(60d)" `
    -Purge

Write-Output "✅ Initiated purge operation: $purgeId"
```

**3. Auto-Scaling Based on Metrics**

```powershell
# AutoScale-AppService.ps1
# Schedule: Every 5 minutes via Azure Automation

$resourceGroupName = "rg-contoso-patient-portal-dev"
$aspName = "asp-contosopat-dev-qkfwso"

# Get current CPU usage
$metrics = Get-AzMetric `
    -ResourceId "/subscriptions/{sub-id}/resourceGroups/$resourceGroupName/providers/Microsoft.Web/serverfarms/$aspName" `
    -MetricName "CpuPercentage" `
    -TimeGrain 00:05:00 `
    -StartTime (Get-Date).AddMinutes(-10)

$avgCPU = ($metrics.Data | Measure-Object -Property Average -Average).Average

$asp = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $aspName
$currentInstances = $asp.Sku.Capacity

# Scale out if CPU >70%, scale in if <30%
if ($avgCPU -gt 70 -and $currentInstances -lt 3) {
    $newInstances = $currentInstances + 1
    Set-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $aspName -NumberofWorkers $newInstances
    Write-Output "⬆️ Scaled out to $newInstances instances (CPU: $avgCPU%)"
} elseif ($avgCPU -lt 30 -and $currentInstances -gt 1) {
    $newInstances = $currentInstances - 1
    Set-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $aspName -NumberofWorkers $newInstances
    Write-Output "⬇️ Scaled in to $newInstances instances (CPU: $avgCPU%)"
} else {
    Write-Output "✅ No scaling needed (CPU: $avgCPU%, Instances: $currentInstances)"
}
```

**4. Certificate Expiration Check**

```powershell
# Check-CertificateExpiration.ps1
# Schedule: Daily at 9:00 AM

$vaultName = "kv-contosop-dev-qkfwso"
$warningThresholdDays = 30

$certificates = Get-AzKeyVaultCertificate -VaultName $vaultName

foreach ($cert in $certificates) {
    $certDetail = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $cert.Name
    $daysUntilExpiry = ($certDetail.Expires - (Get-Date)).Days
    
    if ($daysUntilExpiry -lt $warningThresholdDays) {
        Write-Warning "⚠️ Certificate '$($cert.Name)' expires in $daysUntilExpiry days!"
        # Send alert email here
    } else {
        Write-Output "✅ Certificate '$($cert.Name)' valid for $daysUntilExpiry days"
    }
}
```

---

## 11. Runbook Links & Resources

### Azure Documentation

| Resource Type | Documentation Link |
|--------------|-------------------|
| App Service | [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/) |
| SQL Database | [Azure SQL Database Documentation](https://learn.microsoft.com/azure/azure-sql/database/) |
| Key Vault | [Azure Key Vault Documentation](https://learn.microsoft.com/azure/key-vault/) |
| Application Insights | [Application Insights Documentation](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview) |
| Virtual Network | [Azure Virtual Network Documentation](https://learn.microsoft.com/azure/virtual-network/) |
| Private Endpoints | [Azure Private Link Documentation](https://learn.microsoft.com/azure/private-link/) |

### Internal Resources

- **Architecture Documentation**: `./architecture-documentation.md`
- **Troubleshooting Guide**: `./troubleshooting-guide.md`
- **API Documentation**: `./api-documentation.md`
- **Runbook**: `./runbook-main.md`
- **Deployment Guide**: `../../../infra/bicep/contoso-patient-portal/README.md`

### Escalation Procedures

**Severity Levels**:

| Severity | Response Time | Escalation Path |
|----------|---------------|-----------------|
| **P1 - Critical** | 15 minutes | On-call engineer → Manager → Director |
| **P2 - High** | 1 hour | On-call engineer → Team lead |
| **P3 - Medium** | 4 hours | Ticket assignment to team |
| **P4 - Low** | 24 hours | Standard ticket queue |

**On-Call Contacts**:
- **Primary On-Call**: [Insert phone number]
- **Secondary On-Call**: [Insert phone number]
- **Manager**: [Insert phone number]
- **Azure Support**: 1-800-MICROSOFT

### Support Contacts

- **Microsoft Azure Support**: [Azure Support Portal](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- **Azure Status**: [Azure Status Page](https://status.azure.com/)
- **Internal IT Helpdesk**: [Insert contact info]
- **Database Admin Team**: [Insert contact info]
- **Security Team**: [Insert contact info]

---

## Appendix A: Quick Reference Commands

### Common Operations

```powershell
# Connect to Azure
Connect-AzAccount

# Select subscription
Set-AzContext -Subscription "noalz"

# Get resource group
Get-AzResourceGroup -Name "rg-contoso-patient-portal-dev"

# List all resources
Get-AzResource -ResourceGroupName "rg-contoso-patient-portal-dev"

# Restart App Service
Restart-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"

# Get App Service logs
Get-AzWebAppLog -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso" -Tail 100

# Get SQL Database status
Get-AzSqlDatabase -ResourceGroupName "rg-contoso-patient-portal-dev" -ServerName "sql-contosopat-dev-qkfwso" -DatabaseName "sqldb-patients-dev-qkfwso"

# Get Key Vault secret
Get-AzKeyVaultSecret -VaultName "kv-contosop-dev-qkfwso" -Name "SecretName" -AsPlainText
```

### Emergency Rollback

```powershell
# Rollback App Service deployment
$app = Get-AzWebApp -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso"
$previousDeploymentId = (Get-AzWebAppDeploymentLog -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso" | Select-Object -Skip 1 -First 1).Id
Restore-AzWebAppSnapshot -ResourceGroupName "rg-contoso-patient-portal-dev" -Name "app-contosopat-dev-qkfwso" -SnapshotId $previousDeploymentId
```

---

**Document Version**: 1.0  
**Last Reviewed**: November 20, 2025  
**Next Review**: December 20, 2025  
**Owner**: IT Operations Team

*This Day 2 Operations Guide was generated using GitHub Copilot and tailored to the specific Azure resources in rg-contoso-patient-portal-dev. Update this document as the infrastructure evolves.*


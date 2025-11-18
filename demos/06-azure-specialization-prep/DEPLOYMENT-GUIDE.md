# Deployment Guide

## 🎯 Overview

This guide walks through deploying the complete Contoso Task Manager infrastructure to Azure using the generated Bicep templates.

---

## 📋 Prerequisites

Before deploying, ensure you have:

- ✅ **Azure Subscription** with Contributor access
- ✅ **Azure CLI** (version 2.50.0 or newer) - [Install](https://aka.ms/installazurecli)
- ✅ **Bicep CLI** (version 0.20.0 or newer) - Run: `az bicep install`
- ✅ **PowerShell 7+** - [Install](https://aka.ms/powershell)
- ✅ **GitHub Copilot** with custom agents configured

---

## 🚀 Quick Start (5 minutes)

### 1. Login to Azure

```powershell
az login
az account set --subscription "<your-subscription-id>"
```text

### 2. Deploy Infrastructure

```powershell
cd demos/06-azure-specialization-prep/scripts
.\deploy.ps1 -ResourceGroupName "rg-taskmanager-demo" -Location "eastus" -Environment "prod"
```

**Prompts during deployment:**

- VM Administrator password (12+ chars, complex)
- SQL Administrator password (12+ chars, complex)

**Expected duration:** 15-20 minutes

### 3. Validate Deployment

```powershell
.\validate.ps1 -ResourceGroupName "rg-taskmanager-demo"
```text

### 4. Access Application

Navigate to the public IP address displayed in deployment outputs:

```

http://<public-ip-address>

```yaml

---

## 📝 Detailed Deployment Steps

### Step 1: Review Architecture

The deployment creates:

```

Resource Group (rg-taskmanager-prod)
├── Virtual Network (10.0.0.0/16)
│   ├── Web Subnet (10.0.1.0/24) with NSG
│   └── Data Subnet (10.0.2.0/24) with NSG
├── 2× Windows Server 2022 VMs
│   ├── IIS installed automatically
│   ├── Azure Monitor Agent
│   └── In Availability Set (99.95% SLA)
├── Azure Load Balancer (Standard)
│   ├── Public IP address
│   ├── Backend pool with both VMs
│   └── HTTP/HTTPS load balancing rules
├── Azure SQL Database (Standard S2)
│   ├── 50 DTUs, 10 GB storage
│   ├── TLS 1.2 minimum
│   └── Auditing enabled
└── Monitoring
    ├── Log Analytics workspace
    ├── Application Insights
    └── Alert rules for CPU, memory, SQL, LB

```bicep

**Total estimated cost:** ~$374/month

---

### Step 2: Customize Parameters (Optional)

Edit `infrastructure/parameters/prod.bicepparam` to customize:

```bicep
// Network Configuration
param vnetAddressPrefix = '10.0.0.0/16'
param webSubnetPrefix = '10.0.1.0/24'
param corporateNetworkCidr = '203.0.113.0/24' // Update for RDP access

// VM Configuration
param vmSize = 'Standard_D2s_v3' // Or 'Standard_B2s' for dev
param vmCount = 2 // 2-4 VMs

// Database Configuration
param databaseSku = 'S2' // Or 'Basic' for dev

// Alert Configuration
param alertEmailAddresses = ['ops-team@contoso.com']
```

---

### Step 3: Deploy with What-If Analysis

Preview changes before deploying:

```powershell
.\deploy.ps1 `
    -ResourceGroupName "rg-taskmanager-demo" `
    -Location "eastus" `
    -Environment "prod" `
    -WhatIf
```text

This shows what resources will be created without making changes.

---

### Step 4: Deploy Infrastructure

#### Option A: Interactive Deployment (Recommended)

```powershell
.\deploy.ps1 `
    -ResourceGroupName "rg-taskmanager-demo" `
    -Location "eastus" `
    -Environment "prod"
```

The script will prompt for:

1. VM Administrator password
2. SQL Administrator password

#### Option B: Automated Deployment

```powershell
$adminPassword = ConvertTo-SecureString "YourComplexPassword123!" -AsPlainText -Force
$sqlPassword = ConvertTo-SecureString "YourSqlPassword456!" -AsPlainText -Force

.\deploy.ps1 `
    -ResourceGroupName "rg-taskmanager-demo" `
    -Location "eastus" `
    -Environment "prod" `
    -AdminPassword $adminPassword `
    -SqlAdminPassword $sqlPassword
```yaml

---

### Step 5: Monitor Deployment Progress

#### PowerShell Output

Watch the deployment progress in your terminal:

```

▶️  Checking prerequisites...
✅ Azure CLI version: 2.55.0
✅ Bicep CLI: 0.24.24
✅ Logged in as: user@contoso.com

▶️  Deployment Configuration
   Resource Group: rg-taskmanager-demo
   Location: eastus
   Environment: prod

▶️  Deploying infrastructure...
   This may take 15-20 minutes...

```bicep

#### Azure Portal

Monitor in real-time:

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for your resource group
3. Click **Deployments** in left menu
4. View deployment progress

---

### Step 6: Validate Deployment

Run comprehensive validation tests:

```powershell
.\validate.ps1 -ResourceGroupName "rg-taskmanager-demo"
```

**Validation checks:**

- ✅ Resource group exists
- ✅ Virtual network and subnets configured
- ✅ NSG rules properly set
- ✅ Public IP allocated
- ✅ Load balancer with backend pool
- ✅ 2 VMs running with IIS extension
- ✅ Availability set configured
- ✅ SQL Server with database
- ✅ TLS 1.2 enforced
- ✅ Firewall rules configured
- ✅ Log Analytics workspace
- ✅ Application Insights
- ✅ HTTP endpoint accessible
- ✅ Resource tags applied

**Expected output:**

```yaml
   Passed: 25 / 25 tests (100%)
   
   ✅ All validation tests passed!
   
   Infrastructure is ready for:
   1. Application deployment
   2. Database schema initialization
   3. Production workload testing
```

---

## 🗄️ Database Setup

### 1. Connect to SQL Database

Using Azure Data Studio or SSMS:

```yaml
Server: sql-taskmanager-prod-<unique>.database.windows.net
Database: sqldb-taskmanager-prod
Authentication: SQL Authentication
Username: sqladmin
Password: <your-sql-password>
```

### 2. Run Database Schema

Execute the schema script:

```powershell
cd demos/06-azure-specialization-prep/application/database
sqlcmd -S <sql-server>.database.windows.net -d <database-name> -U sqladmin -P <password> -i schema.sql
```markdown

Or open `schema.sql` in Azure Data Studio and execute.

**This creates:**

- Tasks table with indexes
- 10 sample tasks for testing

---

## 🌐 Application Deployment

### Option 1: Manual Deployment via RDP

1. **Connect to VM1:**

   ```powershell
   # Get VM public IP from load balancer NAT rules
   mstsc /v:<public-ip>:50001
```

2. **Upload application files:**
   - Copy `application/TaskManager.Web/*` to `C:\inetpub\wwwroot\TaskManager\`

3. **Update Web.config:**

   ```xml
   <connectionStrings>
     <add name="TaskManagerDb" 
          connectionString="Server=tcp:sql-taskmanager-prod-<unique>.database.windows.net,1433;Database=sqldb-taskmanager-prod;User ID=sqladmin;Password=<your-password>;Encrypt=True;TrustServerCertificate=False;" 
          providerName="System.Data.SqlClient" />
   </connectionStrings>

```sql

4. **Repeat for VM2**

### Option 2: Automated Deployment with Azure DevOps

Create a pipeline using `azure-pipelines.yml` (not included in this demo).

---

## ✅ Post-Deployment Verification

### 1. Test Application

Navigate to: `http://<public-ip-address>`

**Expected page:**

- Server name displayed (VM hostname)
- Database connection status: ✓ Connected
- Task statistics: Total: 10, Completed: 3, Pending: 7
- Task list with sample data

### 2. Test Load Balancing

Refresh the page multiple times. Server name should alternate between:

- TASKWEB01
- TASKWEB02

### 3. Test CRUD Operations

- **Add Task:** Enter title and description, click Add
- **Complete Task:** Click Complete button on a task
- **Verify Database:** Check Tasks table in SQL Database

### 4. Test Monitoring

**Azure Portal:**

1. Navigate to Application Insights
2. View **Live Metrics** - should show requests
3. Check **Performance** - response times
4. Review **Failures** - should be none

**Log Analytics:**

1. Navigate to Log Analytics workspace
2. Run query:

   ```kql
   AzureDiagnostics
   | where ResourceType == "LOADBALANCERS"
   | where TimeGenerated > ago(1h)
   | summarize count() by TimeGenerated
```

---

## 🚨 Troubleshooting

### Issue: Deployment Fails

**Symptom:** Deployment times out or returns error

**Solutions:**

1. Check quota limits:

   ```powershell
   az vm list-usage --location eastus --output table

```text

2. Review deployment logs in Azure Portal

3. Verify Bicep templates:

   ```powershell
   cd infrastructure
   bicep build main.bicep
```

### Issue: VMs Not Responding

**Symptom:** HTTP endpoint returns timeout

**Solutions:**

1. Check VM status:

   ```powershell
   az vm get-instance-view --resource-group rg-taskmanager-demo --name vm-web01-prod --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus"

```bicep

2. Verify NSG rules allow HTTP:

   ```powershell
   az network nsg rule list --resource-group rg-taskmanager-demo --nsg-name nsg-web-prod --output table
```

3. Check IIS installation (via RDP):

   ```powershell
   Get-WindowsFeature -Name Web-Server

```bicep

### Issue: SQL Connection Fails

**Symptom:** Application shows "Connection Error"

**Solutions:**

1. Verify firewall rules:

   ```powershell
   az sql server firewall-rule list --resource-group rg-taskmanager-demo --server <sql-server-name> --output table
```

2. Test connectivity from VM:

   ```powershell
   Test-NetConnection -ComputerName <sql-server>.database.windows.net -Port 1433

```bash

3. Verify connection string in Web.config

### Issue: Load Balancer Not Distributing Traffic

**Symptom:** Always see same server name

**Solutions:**

1. Check backend pool health:

   ```powershell
   az network lb show --resource-group rg-taskmanager-demo --name lb-web-prod --query "backendAddressPools[0].backendIPConfigurations[].id"
```

2. Verify health probe:

   ```powershell
   az network lb probe show --resource-group rg-taskmanager-demo --lb-name lb-web-prod --name health-probe-http

```sql

3. Check VM health in Azure Portal > Load Balancer > Backend Pools

---

## 🗑️ Cleanup

### Delete All Resources

```powershell
cd demos/06-azure-specialization-prep/scripts
.\cleanup.ps1 -ResourceGroupName "rg-taskmanager-demo"
```

**Prompts for confirmation:**

```text
Type 'DELETE' to confirm deletion
```

**Or force delete without confirmation:**

```powershell
.\cleanup.ps1 -ResourceGroupName "rg-taskmanager-demo" -Force
```bicep

---

## 💰 Cost Management

### Estimated Monthly Costs (East US, Pay-As-You-Go)

| Resource | SKU | Quantity | Monthly Cost |
|----------|-----|----------|--------------|
| Virtual Machines | Standard_D2s_v3 | 2 | $140.16 |
| Managed Disks | Premium SSD P10 | 2 | $19.20 |
| Load Balancer | Standard | 1 | $18.26 |
| Public IP | Static Standard | 1 | $3.65 |
| SQL Database | Standard S2 | 1 | $150.00 |
| Log Analytics | PerGB2018 (5GB/day) | 1 | $35.00 |
| Application Insights | Included | 1 | $0.00 |
| **Total** | | | **~$374/month** |

### Cost Optimization Tips

**For Dev/Testing:**

```bicep
param vmSize = 'Standard_B2s' // $38/month (74% savings)
param databaseSku = 'Basic' // $5/month (97% savings)
param dailyQuotaGb = 1 // $7/month (80% savings)
```

**Estimated dev cost:** ~$95/month (75% savings)

**Shutdown VMs when not in use:**

```powershell
az vm deallocate --resource-group rg-taskmanager-demo --name vm-web01-prod
az vm deallocate --resource-group rg-taskmanager-demo --name vm-web02-prod
```

---

## 📚 Next Steps

1. ✅ **Deploy Infrastructure** - Complete this guide
2. 📊 **Generate Audit Evidence** - Use deployed resources for specialization audit
3. 🎓 **Learn Bicep Best Practices** - Review generated templates
4. 🤖 **Customize Agents** - Modify prompts for your scenarios
5. 🚀 **Deploy to Production** - Adapt for customer environments

---

## 📞 Support Resources

- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/architecture/framework/)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

---

**Last Updated:** November 2025  
**Version:** 1.0

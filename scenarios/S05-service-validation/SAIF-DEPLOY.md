---
post_title: "SAIF Deployment Guide"
author1: "SAIF Team"
post_slug: "saif-deployment-guide"
microsoft_alias: "saifteam"
featured_image: ""
categories: ["Infrastructure", "Azure"]
tags: ["Bicep", "PowerShell", "Containers"]
ai_note: "Content reviewed with AI assistance."
summary: "One‑click deployment of SAIF using PowerShell or Azure Portal, including infra, containers, and diagnostics."
post_date: "2025-09-03"
---

## 🚀 Fully Automated Deployment Options

SAIF provides **true 1-click deployment** with complete automation including infrastructure, container builds, and configuration.

### Option 1: Version Chooser (🏆 Recommended)

Run a single interactive script to pick v1 (classic SQL auth) or v2 (Entra/Managed Identity to SQL):

```powershell
# Clone and deploy; choose v1 or v2 when prompted
git clone https://github.com/jonathan-vella/SAIF.git
cd SAIF
.\scripts\Deploy-SAIF.ps1
```

**✅ What this automates:**
- ✅ Resource group creation and tagging
- ✅ All Azure infrastructure (ACR, App Services, SQL, Monitoring)
- ✅ Managed identities and RBAC permissions (AcrPull)
- ✅ Application Insights configuration
- ✅ Container builds and pushes
- ✅ App Service restarts and validation
- ✅ P1v3 SKU and Always On configuration
- ✅ Prompts for Application and Owner tags (Owner defaults to signed-in Azure user)

**⏱️ Total time:** ~15-20 minutes

### Option 2: Direct v1 or v2 Deployment

Deploy a specific version without the chooser:

```powershell
# v1: SQL username/password to Azure SQL (training baseline)
.\scripts\Deploy-SAIF-v1.ps1

# v2: Microsoft Entra (Managed Identity) authentication to Azure SQL
.\scripts\Deploy-SAIF-v2.ps1
# Notes (v2):
# - Now also auto‑configures SQL firewall for your public IP and creates the DB user for the API's managed identity
# - Use these optional flags:
#   -skipSqlAccessConfig  # skip firewall/user/roles configuration
#   -FirewallRuleName "my-laptop"  # name for your client IP rule
#   -GrantRoles db_datareader,db_datawriter  # roles granted to the MI user (default: db_datareader)
#   -UserAssignedClientId <guid>  # if your API uses a User‑Assigned MI
```

### Option 3: Deploy to Azure Button + Container Build

For Azure Portal enthusiasts:

**Step 1:** Deploy infrastructure via Azure Portal
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjonathan-vella%2FSAIF%2Fmain%2Finfra%2Fazuredeploy.json)

**Step 2:** Build and deploy containers
```powershell
git clone https://github.com/jonathan-vella/SAIF.git
cd SAIF
.\scripts\Update-SAIF-Containers.ps1
```

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fjonathan-vella%2FSAIF%2Fmain%2Finfra%2Fazuredeploy.json)

Note: The portal button deploys the v1 infrastructure. The v2 (Managed Identity to SQL) path is available through the PowerShell options above.

## 📋 What Gets Deployed (Fully Automated)

The automated deployment creates a complete hackathon environment:

### 🏗️ Infrastructure (All Automated)
- Resource Group: `rg-saifv1-swc01` (Sweden Central) or `rg-saifv1-gwc01` (Germany West Central)
- Azure Container Registry: Standard SKU with managed identity authentication
- App Service Plan: Linux Premium P1v3 tier with Always On enabled
- API App Service: Python FastAPI backend (container)
- Web App Service: PHP frontend (container)
- Azure SQL Server and Database: S1 tier
- Log Analytics Workspace + Application Insights
 - (v2) Consolidated diagnostics bundle attaches three diagnostic settings (API, Web, SQL) via single module

### 🔐 Security Configuration (All Automated)
- Managed Identities: System-assigned identities on both App Services (used for ACR and, in v2, for SQL)
- RBAC: AcrPull roles assigned to identities for ACR image pulls
	- Stable GUID salt (subscription + ACR name + principalId) prevents unnecessary role assignment recreation on template refactors
- ACR Authentication: Uses managed identity (no admin credentials)
- Application Insights: Connection strings automatically configured
- SQL Authentication: Behavior differs by version (see below)

### 🔁 v1 vs v2 Authentication
- v1 (baseline for training): API connects to SQL using SQL username/password.
- v2 (more secure path): API connects to SQL using Microsoft Entra (Managed Identity) with token-based auth.

### 🐳 Container Deployment (Automated via PowerShell)
- **API Container**: Built from `./api` and pushed as `saif/api:latest`
- **Web Container**: Built from `./web` and pushed as `saif/web:latest`
- **App Service Configuration**: Containers automatically configured and started

## 🛠️ Available Scripts

### Primary Deployment Scripts

| Script | Purpose | Automation Level |
|--------|---------|------------------|
| **`Deploy-SAIF.ps1`** | Interactive chooser for v1 or v2 full deployment | 🟢 **100% Automated** |
| **`Deploy-SAIF-v1.ps1`** | Full v1 deployment including containers | 🟢 **100% Automated** |
| **`Deploy-SAIF-v2.ps1`** | Full v2 deployment (Entra MI to SQL) including containers | 🟢 **100% Automated** |
| **`Configure-SAIF-SqlAccess.ps1`** | Manually configure SQL firewall and MI DB user/roles (invoked by v2 deploy; run only if you used -skipSqlAccessConfig) | 🟢 **Automated Helper** |
| **`Update-SAIF-Containers.ps1`** | Update v1 containers only | 🟢 **100% Automated** |
| **`Update-SAIF-Containers-v2.ps1`** | Update v2 API container only | 🟢 **100% Automated** |

### Script Examples

**Complete deployment:**
```powershell
# Launch version chooser (default region: Germany West Central)
.\scripts\Deploy-SAIF.ps1

# Direct v1 to Sweden Central
.\scripts\Deploy-SAIF-v1.ps1 -location "swedencentral"

# Direct v2 using Managed Identity to SQL
.\scripts\Deploy-SAIF-v2.ps1

# v2 with custom firewall rule name and roles
.\scripts\Deploy-SAIF-v2.ps1 -ResourceGroupName rg-saifv2-gwc01 -FirewallRuleName "dev-laptop" -GrantRoles db_datareader,db_datawriter

# v2 infra/containers only (skip firewall and DB user/roles)
.\scripts\Deploy-SAIF-v2.ps1 -skipSqlAccessConfig

# Deploy v1 infrastructure only (skip containers)
.\scripts\Deploy-SAIF-v1.ps1 -skipContainers
```

**Container updates only:**
```powershell
# Update both containers
.\scripts\Update-SAIF-Containers.ps1

# Update only API container
.\scripts\Update-SAIF-Containers.ps1 -buildApi

# Update only Web container  
.\scripts\Update-SAIF-Containers.ps1 -buildWeb

# Deploy to different region
.\scripts\Update-SAIF-Containers.ps1 -location "germanywestcentral"
```

## 🔄 Container Updates

After making changes to your application code, update containers easily:

```powershell
# Update both containers
.\scripts\Update-SAIF-Containers.ps1

# Update only API container
.\scripts\Update-SAIF-Containers.ps1 -buildApi

# Update only Web container  
.\scripts\Update-SAIF-Containers.ps1 -buildWeb

# v2: Update only the API container
.\scripts\Update-SAIF-Containers-v2.ps1
```

**What this automates:**
- ✅ Builds containers from source code
- ✅ Pushes to Azure Container Registry
- ✅ Restarts App Services to pull new images
- ✅ Validates deployment

## 📍 Deployment Regions

Choose from supported regions:
- **Germany West Central** (`germanywestcentral`) - Default
- **Sweden Central** (`swedencentral`)

## 🔧 Prerequisites

### For PowerShell Automation (Recommended):
- ✅ Azure CLI installed and logged in (`az login`)
- ✅ PowerShell 5.1+ or PowerShell Core 7+
- ✅ Docker (for container builds)
- ✅ Git (for repository cloning)

### For Deploy to Azure Button:
- ✅ Azure subscription with Contributor access
- ✅ Browser access to Azure Portal
- ✅ PowerShell + Azure CLI (for follow-up container build)

### Automatic Validation:
Both deployment methods include automatic prerequisite checking and clear error messages.

## 🎯 Post-Deployment

After successful deployment, you'll receive output like:

```
🎉 SAIF Deployment Complete!
Resource Group: rg-saifv1-swc01
API URL: https://app-saif-api-axxq5b.azurewebsites.net
Web URL: https://app-saif-web-axxq5b.azurewebsites.net

# If you deployed v2, resource names include "-v2-" and the API uses Entra (Managed Identity) to access SQL.
```

### ✅ Automatic Configuration Verification
- **Managed Identity**: ✅ Assigned to both App Services (ACR pulls; v2 also uses MI for SQL)
- **Container Registry Access**: ✅ Verified
- **Application Insights**: ✅ Connected
- **Always On**: ✅ Enabled
- **P1v3 Performance Tier**: ✅ Configured
- **v2 SQL Access**: ✅ Firewall rule and DB user/roles configured (unless -skipSqlAccessConfig used)

### 🌐 Access Your Application
1. **Web Interface**: Visit the Web URL for the diagnostic dashboard
2. **API Documentation**: Visit `{API_URL}/docs` for interactive API documentation
3. **Monitoring**: Application Insights automatically collects telemetry
4. **Database**: SQL Server accessible from App Services. For v2, validate MI with:
	- `{API_URL}/api/sqlwhoami` (returns DB, login/user, roles)
	- `{API_URL}/api/sqlsrcip` (returns SQL‑seen client IP)

## 📊 Monitoring

Access monitoring data through:
- **Application Insights**: Performance and error tracking
- **Log Analytics**: Detailed logging and queries
- **Azure Portal**: Resource health and metrics

## 🧹 Cleanup

To remove all resources:

```powershell
# Delete entire resource group (WARNING: This deletes everything!)
az group delete --name rg-saifv1-swc01 --yes --no-wait
```

## 🏷️ Tags Applied

All resources receive a consistent tag set:

- Environment: hackathon
- Application: prompted during deployment (default: SAIF)
- Owner: defaults to the signed-in Azure user (overrideable)
- CreatedBy: Bicep
- LastModified: deployment date (yyyy-MM-dd)
- Purpose: Security Training
- Plus any additional values provided via the `tags` parameter

Note: Defaults are merged with provided tags using `union(tags, defaults)`. If you want provided tags to override defaults, flip the merge order.

## 🔍 Optional: Preview and Non‑Interactive

- Preview changes (what‑if):
	```powershell
	az deployment group what-if `
		--resource-group <rg-name> `
		--template-file ./infra/main.bicep `
		--parameters ./infra/main.parameters.json sqlAdminPassword=<secure>
	```

- Non‑interactive deploy with parameter file:
	```powershell
	az deployment group create `
		--resource-group <rg-name> `
		--template-file ./infra/main.bicep `
		--parameters ./infra/main.parameters.json applicationName="SAIF" owner="<you>" sqlAdminPassword=<secure>
	```

## 🔍 Troubleshooting

### Common Issues

**Container Build Fails**
```powershell
# Check Docker is running
docker version

# Verify Azure CLI login
az account show
```

**App Service Shows "Application Error"**
```powershell
# Check container logs
az webapp log tail --name your-app-name --resource-group rg-saifv1-swc01

# Verify container registry permissions
az role assignment list --assignee $(az webapp identity show --name your-app-name --resource-group rg-saifv1-swc01 --query principalId -o tsv)
```

**SQL Connection Issues**
- v2: If you deployed with -skipSqlAccessConfig, run:
	- `./scripts/Configure-SAIF-SqlAccess.ps1 -ResourceGroupName <rg>` (adds firewall rule, creates MI DB user, grants roles)
- Verify firewall rules include your client IP if you need direct SQL access
- Confirm app settings SQL_SERVER/SQL_DATABASE point to the expected DB

### Support
For deployment issues, check:
1. [Azure Resource Group Activity Log](https://portal.azure.com)
2. Application Insights for runtime errors
3. Container Registry build history

## 🔐 v2: Entra (Managed Identity) to Azure SQL

When deploying v2 via the chooser or `Deploy-SAIF-v2.ps1`:

- The script prompts for an Azure SQL AAD admin (user or group) and sets it on the SQL server. The AAD ObjectId is auto‑resolved (user → group → signed‑in user), no GUID prompt required.
- The API container connects to Azure SQL using a token from Managed Identity.
- Database principal creation for the web/API is automated using `az sql db query` with an Entra token, with `sqlcmd -G` as a fallback. If both are unavailable, the script prints the T‑SQL to run manually.
- All educational vulnerabilities on the API endpoints remain for training purposes (permissive CORS, env exposure, SQLi surface, etc.), but credentials are not stored in app settings.

Tip: Ensure the Azure CLI SQL extension is available for the `az sql` path; the script detects and falls back if needed.

## ♻️ v2 Modularization & Diagnostics Bundle

The v2 infrastructure template was modularized to align with maintainability goals:

- New `aadAdmin` module sets Azure SQL Entra administrator
- Consolidated `diagnosticsBundle` module replaces prior individual diagnostics modules (API, Web, SQL)
- Security `roleAcrPull` module GUID salt realigned for stability (prevents drift-induced reassignments)

Why the bundle? Fewer module calls and reduced duplication while preserving the original diagnostic setting names to avoid churn in existing workspaces and Log Analytics queries.

Observability Impact: All previous log/metric categories remain enabled (broad for training). In production you would trim categories, add retention tuning, and enable threat detection policies.

Rollback: If you ever need to split diagnostics again, you can reintroduce per‑resource modules without affecting outputs—resource names are preserved in the bundle (`ds-api-v2-*`, `ds-web-v2-*`, `ds-sql-v2-*`).

No Output Changes: All published outputs (ACR, App Services, URLs, SQL FQDN, Workspace Id) remain unchanged to protect downstream automation.

Note: v2 deployment and update scripts also build and push the web container (`saif/web:latest`) into the v2 ACR so the v2 web app can pull successfully.

## 📈 Scaling

The deployment uses PremiumV3 P1v3 for App Service Plan and S1 for SQL DB by default (training environment). For production use:

- Upgrade App Service Plan to Standard or Premium
- Consider Azure SQL Database scaling options
- Add Azure Front Door for global distribution
- Implement proper security configurations

---

**Ready to deploy?** Click the "Deploy to Azure" button at the top of this page!

# Deployment Validation Checklist

Use this checklist to validate the Bicep implementation before and after deployment.

## ✅ Pre-Deployment Validation

### Environment Setup

- [ ] Azure CLI installed (version 2.50.0+)
  ```powershell
  az version
  ```

- [ ] Bicep CLI installed (version 0.20.0+)
  ```powershell
  az bicep version
  ```

- [ ] Logged into Azure
  ```powershell
  az account show
  ```

- [ ] Correct subscription selected
  ```powershell
  az account set --subscription <subscription-id>
  ```

### Template Validation

- [ ] Bicep restore completed
  ```powershell
  cd infra/bicep/contoso-patient-portal
  bicep restore main.bicep
  ```

- [ ] Bicep build passes
  ```powershell
  bicep build main.bicep --stdout --no-restore
  ```

- [ ] Bicep lint passes (only warnings acceptable)
  ```powershell
  bicep lint main.bicep
  ```

- [ ] All templates formatted
  ```powershell
  bicep format main.bicep
  ```

### Parameter Validation

- [ ] SQL admin password meets complexity requirements
  - Minimum 8 characters
  - Contains uppercase letter
  - Contains lowercase letter
  - Contains number
  - Contains special character

- [ ] Environment parameter is valid (dev/staging/prod)

- [ ] Location is valid Azure region (eastus2, westus2, etc.)

- [ ] Tags are appropriate for organization

### What-If Analysis

- [ ] Run what-if to preview changes
  ```powershell
  .\deploy.ps1 -WhatIf
  ```

- [ ] Review what-if output for unexpected changes

- [ ] Verify estimated costs align with budget

- [ ] No critical warnings or errors in what-if output

## 📋 Deployment Validation

### Phase 1: Foundation & Networking

- [ ] Resource Group created
  ```powershell
  az group show --name rg-contoso-patient-portal-prod
  ```

- [ ] Virtual Network deployed
  ```powershell
  az network vnet show --resource-group rg-contoso-patient-portal-prod --name vnet-contoso-patient-portal-prod-eastus2
  ```

- [ ] 3 Subnets created
  ```powershell
  az network vnet subnet list --resource-group rg-contoso-patient-portal-prod --vnet-name vnet-contoso-patient-portal-prod-eastus2 -o table
  ```

- [ ] NSG for web tier created
  ```powershell
  az network nsg show --resource-group rg-contoso-patient-portal-prod --name nsg-web-prod
  ```

- [ ] NSG for data tier created
  ```powershell
  az network nsg show --resource-group rg-contoso-patient-portal-prod --name nsg-data-prod
  ```

- [ ] NSGs associated with subnets
  ```powershell
  az network vnet subnet show --resource-group rg-contoso-patient-portal-prod --vnet-name vnet-contoso-patient-portal-prod-eastus2 --name snet-web-prod --query networkSecurityGroup.id
  ```

### Phase 2: Platform Services

- [ ] Log Analytics Workspace created
  ```powershell
  az monitor log-analytics workspace show --resource-group rg-contoso-patient-portal-prod --workspace-name log-contoso-patient-portal-prod
  ```

- [ ] Application Insights created
  ```powershell
  az monitor app-insights component show --resource-group rg-contoso-patient-portal-prod --app appi-contoso-patient-portal-prod
  ```

- [ ] App Service Plan created (Standard S1, 2 instances)
  ```powershell
  az appservice plan show --resource-group rg-contoso-patient-portal-prod --name asp-contoso-patient-portal-prod
  ```

- [ ] App Service Plan is zone-redundant
  ```powershell
  az appservice plan show --resource-group rg-contoso-patient-portal-prod --name asp-contoso-patient-portal-prod --query zoneRedundant
  ```

- [ ] SQL Server created
  ```powershell
  az sql server show --resource-group rg-contoso-patient-portal-prod --name sql-contoso-patient-portal-prod-<uniqueString>
  ```

- [ ] Key Vault created
  ```powershell
  az keyvault show --resource-group rg-contoso-patient-portal-prod --name kv-<uniqueString>
  ```

### Phase 3: Security & Application

- [ ] SQL Database created (Standard S2)
  ```powershell
  az sql db show --resource-group rg-contoso-patient-portal-prod --server sql-contoso-patient-portal-prod-<uniqueString> --name sqldb-patients-prod
  ```

- [ ] TDE enabled on SQL Database
  ```powershell
  az sql db tde show --resource-group rg-contoso-patient-portal-prod --server sql-contoso-patient-portal-prod-<uniqueString> --database sqldb-patients-prod
  ```

- [ ] Private Endpoint for Key Vault created
  ```powershell
  az network private-endpoint show --resource-group rg-contoso-patient-portal-prod --name pe-keyvault-prod
  ```

- [ ] Private Endpoint for SQL Server created
  ```powershell
  az network private-endpoint show --resource-group rg-contoso-patient-portal-prod --name pe-sqlserver-prod
  ```

- [ ] Private DNS zones created
  ```powershell
  az network private-dns zone list --resource-group rg-contoso-patient-portal-prod -o table
  ```

- [ ] App Service created
  ```powershell
  az webapp show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod
  ```

- [ ] App Service has managed identity
  ```powershell
  az webapp identity show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod
  ```

- [ ] App Service VNet integration configured
  ```powershell
  az webapp vnet-integration list --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod
  ```

### Phase 4: Configuration & Access

- [ ] Secrets stored in Key Vault
  ```powershell
  az keyvault secret list --vault-name kv-<uniqueString> -o table
  ```

- [ ] RBAC role assigned to App Service
  ```powershell
  az role assignment list --assignee <app-service-principal-id> --scope /subscriptions/<sub-id>/resourceGroups/rg-contoso-patient-portal-prod/providers/Microsoft.KeyVault/vaults/kv-<uniqueString> -o table
  ```

## 🔒 Security Validation

### Network Security

- [ ] SQL Server public access disabled
  ```powershell
  az sql server show --resource-group rg-contoso-patient-portal-prod --name sql-contoso-patient-portal-prod-<uniqueString> --query publicNetworkAccess
  ```

- [ ] Key Vault public access disabled
  ```powershell
  az keyvault show --resource-group rg-contoso-patient-portal-prod --name kv-<uniqueString> --query properties.publicNetworkAccess
  ```

- [ ] NSG rules configured correctly
  ```powershell
  az network nsg rule list --resource-group rg-contoso-patient-portal-prod --nsg-name nsg-web-prod -o table
  az network nsg rule list --resource-group rg-contoso-patient-portal-prod --nsg-name nsg-data-prod -o table
  ```

### Encryption

- [ ] App Service HTTPS only enabled
  ```powershell
  az webapp show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod --query httpsOnly
  ```

- [ ] App Service TLS 1.2 minimum
  ```powershell
  az webapp config show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod --query minTlsVersion
  ```

- [ ] App Service FTP disabled
  ```powershell
  az webapp config show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod --query ftpsState
  ```

- [ ] SQL Server TLS 1.2 minimum
  ```powershell
  az sql server show --resource-group rg-contoso-patient-portal-prod --name sql-contoso-patient-portal-prod-<uniqueString> --query minimalTlsVersion
  ```

### Access Control

- [ ] Key Vault soft delete enabled
  ```powershell
  az keyvault show --resource-group rg-contoso-patient-portal-prod --name kv-<uniqueString> --query properties.enableSoftDelete
  ```

- [ ] Key Vault purge protection enabled
  ```powershell
  az keyvault show --resource-group rg-contoso-patient-portal-prod --name kv-<uniqueString> --query properties.enablePurgeProtection
  ```

- [ ] Key Vault RBAC enabled
  ```powershell
  az keyvault show --resource-group rg-contoso-patient-portal-prod --name kv-<uniqueString> --query properties.enableRbacAuthorization
  ```

## 🧪 Functional Validation

### App Service

- [ ] App Service URL accessible
  ```powershell
  $appUrl = az webapp show --resource-group rg-contoso-patient-portal-prod --name app-contoso-patient-portal-prod --query defaultHostName -o tsv
  curl "https://$appUrl"
  ```

- [ ] App Service responds with expected content

- [ ] App Service redirects HTTP to HTTPS
  ```powershell
  curl "http://$appUrl" -I
  ```

### Monitoring

- [ ] Application Insights receiving data
  ```powershell
  az monitor app-insights component show --resource-group rg-contoso-patient-portal-prod --app appi-contoso-patient-portal-prod --query connectionString
  ```

- [ ] Log Analytics collecting logs
  ```powershell
  az monitor log-analytics workspace show --resource-group rg-contoso-patient-portal-prod --workspace-name log-contoso-patient-portal-prod --query customerId
  ```

### Database

- [ ] SQL Database accessible via private endpoint (requires VPN/Bastion)

- [ ] SQL Database backup retention configured
  ```powershell
  az sql db show --resource-group rg-contoso-patient-portal-prod --server sql-contoso-patient-portal-prod-<uniqueString> --name sqldb-patients-prod --query requestedBackupStorageRedundancy
  ```

### Key Vault

- [ ] App Service can read secrets from Key Vault (test with application)

- [ ] Key Vault access logs appear in Log Analytics
  ```powershell
  az monitor diagnostic-settings list --resource /subscriptions/<sub-id>/resourceGroups/rg-contoso-patient-portal-prod/providers/Microsoft.KeyVault/vaults/kv-<uniqueString> -o table
  ```

## 💰 Cost Validation

- [ ] Review actual costs in Azure Portal (Cost Management + Billing)

- [ ] Costs align with estimates ($331-346/month)

- [ ] No unexpected resources deployed

- [ ] Resource SKUs match specifications
  - App Service Plan: Standard S1, 2 instances
  - SQL Database: Standard S2, 50 DTU
  - Key Vault: Standard
  - Private Endpoints: 2 endpoints

## 📊 Tagging Validation

- [ ] All resources have required tags
  ```powershell
  az resource list --resource-group rg-contoso-patient-portal-prod --query "[].{Name:name, Tags:tags}" -o table
  ```

- [ ] Tags include:
  - Environment: prod
  - ManagedBy: Bicep
  - Project: PatientPortal
  - CostCenter: Healthcare-IT
  - Compliance: HIPAA

## 🎯 Compliance Validation

### HIPAA Requirements

- [ ] Encryption at rest enabled (TDE for SQL Database)

- [ ] Encryption in transit enforced (TLS 1.2 minimum)

- [ ] Audit logging enabled (all services log to Log Analytics)

- [ ] Access controls implemented (RBAC, managed identities)

- [ ] Network isolation configured (private endpoints)

- [ ] Backup and retention policies set (35-day SQL backup)

## 📝 Documentation Validation

- [ ] README.md complete and accurate

- [ ] IMPLEMENTATION-SUMMARY.md up to date

- [ ] deploy.ps1 script functional

- [ ] Comments in Bicep templates clear and helpful

## 🔄 Rollback Validation

- [ ] Documented rollback procedure tested (optional)

- [ ] Resource deletion commands verified
  ```powershell
  # CAUTION: This will delete all resources!
  # az group delete --name rg-contoso-patient-portal-prod --yes --no-wait
  ```

## ✅ Sign-Off

**Validation Completed By**: _______________________  
**Date**: _______________________  
**Environment**: [ ] Dev  [ ] Staging  [ ] Production  
**Status**: [ ] Pass  [ ] Fail  
**Notes**:

---

## 📋 Issues Found

| Issue | Severity | Status | Notes |
|-------|----------|--------|-------|
|       |          |        |       |
|       |          |        |       |
|       |          |        |       |

---

**Next Steps**: _______________________

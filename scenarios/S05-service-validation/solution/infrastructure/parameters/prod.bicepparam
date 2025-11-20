// prod.bicepparam - Production Environment Parameters
// Purpose: Parameter values for production deployment

using '../main.bicep'

// Environment Configuration
param location = 'eastus'
param environment = 'prod'

// Network Configuration
param vnetAddressPrefix = '10.0.0.0/16'
param webSubnetPrefix = '10.0.1.0/24'
param dataSubnetPrefix = '10.0.2.0/24'
param corporateNetworkCidr = '203.0.113.0/24' // Update with actual corporate network

// VM Configuration
param adminUsername = 'azureadmin'
// Note: adminPassword must be provided at deployment time via secure parameter
param vmSize = 'Standard_D2s_v3'
param vmCount = 2

// Database Configuration
param sqlAdminUsername = 'sqladmin'
// Note: sqlAdminPassword must be provided at deployment time via secure parameter
param databaseSku = 'S2'

// Alert Configuration
param alertEmailAddresses = [
  'ops-team@contoso.com'
]

// Tags
param tags = {
  Environment: 'Production'
  Project: 'TaskManager'
  ManagedBy: 'Bicep'
  Owner: 'IT-Ops'
  SLA: '99.99%'
  CostCenter: 'IT-Operations'
  AuditRequired: 'Yes'
  Compliance: 'Azure-Specialization'
}

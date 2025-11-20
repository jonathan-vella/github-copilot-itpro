// database.bicep - Database Infrastructure Module
// Purpose: Deploys Azure SQL Server and Database with security configurations

targetScope = 'resourceGroup'

// ============================================
// PARAMETERS
// ============================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('SQL Server administrator username')
param sqlAdminUsername string

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('Database name')
param databaseName string = 'sqldb-taskmanager'

@description('SQL Database SKU')
@allowed([
  'Basic'
  'S0'
  'S1'
  'S2'
  'S3'
])
param databaseSku string = 'S2'

@description('Web subnet CIDR for firewall rule')
param webSubnetCidr string

@description('Log Analytics workspace resource ID for auditing')
param logAnalyticsWorkspaceId string

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var sqlServerName = 'sql-taskmanager-${environment}-${uniqueString(resourceGroup().id)}'
var databaseFullName = '${databaseName}-${environment}'

// Database size mapping
var databaseSizeMap = {
  Basic: 2147483648 // 2 GB
  S0: 268435456000 // 250 GB
  S1: 268435456000 // 250 GB
  S2: 268435456000 // 250 GB
  S3: 268435456000 // 250 GB
}

// ============================================
// RESOURCES
// ============================================

// Azure SQL Server (Logical Server)
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseFullName
  location: location
  tags: tags
  sku: {
    name: databaseSku
    tier: databaseSku == 'Basic' ? 'Basic' : 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: databaseSizeMap[databaseSku]
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
  }
}

// Firewall Rule - Allow Azure Services
resource firewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Firewall Rule - Allow Web Subnet
resource firewallRuleWeb 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowWebSubnet'
  properties: {
    startIpAddress: split(webSubnetCidr, '/')[0]
    endIpAddress: split(webSubnetCidr, '/')[0]
  }
}

// Transparent Data Encryption (enabled by default)
resource transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-05-01-preview' = {
  parent: sqlDatabase
  name: 'current'
  properties: {
    state: 'Enabled'
  }
}

// Auditing Settings
resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

// Diagnostic Settings for Database
resource databaseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${databaseFullName}-diagnostics'
  scope: sqlDatabase
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'AutomaticTuning'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'Deadlocks'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('SQL Server resource ID')
output sqlServerId string = sqlServer.id

@description('SQL Server name')
output sqlServerName string = sqlServer.name

@description('SQL Server fully qualified domain name')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('Database resource ID')
output databaseId string = sqlDatabase.id

@description('Database name')
output databaseName string = sqlDatabase.name

@description('Connection string template (add password)')
output connectionStringTemplate string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlAdminUsername};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

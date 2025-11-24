// SAIF v2 Infrastructure - Managed Identity SQL auth for API
metadata name = 'SAIF v2 Infrastructure'
metadata description = 'Deploys SAIF v2 with API using Microsoft Entra (managed identity) to access Azure SQL'
metadata owner = 'SAIF Team'
metadata version = '2.0.0'
metadata lastUpdated = '2025-09-03'
metadata documentation = 'https://github.com/your-org/saif/blob/main/docs/DEPLOY-v2.md'

@description('Azure region')
@allowed([
  'swedencentral'
  'germanywestcentral'
])
param location string = 'germanywestcentral'

@description('Tags object to apply to resources')
param tags object = {}

@description('Application name tag')
param applicationName string = 'SAIF'

@description('Owner tag')
param owner string = ''

@description('CreatedBy tag')
param createdBy string = 'Bicep'

@description('Last modified date tag (yyyy-MM-dd)')
param lastModified string = utcNow('yyyy-MM-dd')

@description('SQL administrator login username (kept for compatibility; not used by API v2)')
param sqlAdminLogin string = 'saifadmin'

@description('SQL administrator login password (kept for compatibility; not used by API v2)')
@secure()
@minLength(12)
param sqlAdminPassword string

@description('Azure AD admin login (UPN or display name) to set on SQL Server')
param aadAdminLogin string

@description('Azure AD admin objectId (GUID) to set on SQL Server')
param aadAdminObjectId string

// Variables
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var acrName = 'acrsaif${uniqueSuffix}'
var appServicePlanName = 'plan-saifv2-${uniqueSuffix}'
var apiAppServiceName = 'app-saifv2-api-${uniqueSuffix}'
var webAppServiceName = 'app-saifv2-web-${uniqueSuffix}'
var sqlServerName = 'sql-saifv2-${uniqueSuffix}'
var sqlDatabaseName = 'saifdb'
var logAnalyticsName = 'log-saifv2-${uniqueSuffix}'
var appInsightsName = 'ai-saifv2-${uniqueSuffix}'

// Default tags
var defaultTags = union(tags, {
  Environment: 'hackathon'
  Application: applicationName
  Owner: owner != '' ? owner : 'Unknown'
  CreatedBy: createdBy
  LastModified: lastModified
  Purpose: 'Security Training'
})

// Observability
module observability './modules/observability/logging.bicep' = {
  name: 'observability-v2-${uniqueSuffix}'
  params: {
    location: location
    tags: defaultTags
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
    workspaceSku: 'PerGB2018'
    retentionInDays: 30
  }
}

// Container Registry
module acr './modules/container/registry.bicep' = {
  name: 'acr-v2-${uniqueSuffix}'
  params: {
    name: acrName
    location: location
    tags: defaultTags
    skuName: 'Standard'
    adminUserEnabled: false
  }
}

// SQL Server (keeps public access for SAIF training)
module sqlServer './modules/sql/server.bicep' = {
  name: 'sql-v2-${uniqueSuffix}'
  params: {
    name: sqlServerName
    location: location
    tags: defaultTags
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminObjectId
  }
}

// Note: Azure AD admin is now configured directly in the SQL Server module above
// The separate aadAdmin module is no longer needed to avoid conflicts

// SQL Database
module sqlDatabase './modules/sql/database.bicep' = {
  name: 'sqldb-v2-${uniqueSuffix}'
  dependsOn: [sqlServer]
  params: {
    location: location
    tags: defaultTags
    serverName: sqlServerName
    name: sqlDatabaseName
    skuName: 'S1'
    skuTier: 'Standard'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

// Firewall rule 0.0.0.0 (Allow Azure Services)
module sqlFirewall './modules/sql/firewallAllowAzure.bicep' = {
  name: 'sqlfw-v2-${uniqueSuffix}'
  dependsOn: [sqlServer]
  params: {
    serverName: sqlServerName
  }
}

// App Service Plan (Linux)
module appServicePlan './modules/web/plan.bicep' = {
  name: 'plan-v2-${uniqueSuffix}'
  params: {
    name: appServicePlanName
    location: location
    tags: defaultTags
    skuName: 'P1v3'
    skuTier: 'PremiumV3'
  }
}

// API App Service (container) - uses MI to access SQL
module apiAppService './modules/web/site.bicep' = {
  name: 'api-v2-${uniqueSuffix}'
  params: {
    name: apiAppServiceName
    location: location
    tags: defaultTags
    serverFarmId: appServicePlan.outputs.id
    image: '${acr.outputs.loginServer}/saifv2/api:latest'
    websitesPort: '8000'
    healthCheckPath: '/api/healthcheck'
    appSettings: [
      { name: 'SQL_SERVER', value: sqlServer.outputs.fullyQualifiedDomainName }
      { name: 'SQL_DATABASE', value: sqlDatabaseName }
      // NOTE: No SQL username/password in v2; API uses managed identity token.
      { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: observability.outputs.appInsightsConnectionString }
    ]
  }
}

// Web App Service (container) - reuse v1 web image
module webAppService './modules/web/site.bicep' = {
  name: 'web-v2-${uniqueSuffix}'
  params: {
    name: webAppServiceName
    location: location
    tags: defaultTags
    serverFarmId: appServicePlan.outputs.id
    image: '${acr.outputs.loginServer}/saif/web:latest'
    websitesPort: '80'
    healthCheckPath: '/'
    appSettings: [
      { name: 'API_URL', value: 'https://${apiAppService.outputs.defaultHostName}' }
      { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: observability.outputs.appInsightsConnectionString }
    ]
  }
}

// Diagnostics (bundled single module replacing individual site/sql diagnostics)
module diagnosticsBundle './modules/diagnostics/diagnosticsBundle.bicep' = {
  name: 'diag-bundle-v2-${uniqueSuffix}'
  params: {
    apiSiteName: apiAppServiceName
    webSiteName: webAppServiceName
    sqlServerName: sqlServerName
    workspaceId: observability.outputs.logAnalyticsId
    uniqueSuffix: uniqueSuffix
  }
  dependsOn: [apiAppService, webAppService, sqlServer]
}

// RBAC AcrPull to ACR
// AcrPull role assignments (module-based)
module apiAcrPull './modules/security/roleAcrPull.bicep' = {
  name: 'ra-api-v2-${uniqueSuffix}'
  params: {
    acrName: acrName
    principalId: apiAppService.outputs.principalId
  }
}

module webAcrPull './modules/security/roleAcrPull.bicep' = {
  name: 'ra-web-v2-${uniqueSuffix}'
  params: {
    acrName: acrName
    principalId: webAppService.outputs.principalId
  }
}

// Outputs
output resourceGroupName string = resourceGroup().name
output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output apiAppServiceName string = apiAppService.outputs.name
output webAppServiceName string = webAppService.outputs.name
output apiUrl string = 'https://${apiAppService.outputs.defaultHostName}'
output webUrl string = 'https://${webAppService.outputs.defaultHostName}'
output sqlServerName string = sqlServerName
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabaseName
output logAnalyticsWorkspaceId string = observability.outputs.logAnalyticsId

// Observability module: Log Analytics + Application Insights (workspace-based)
metadata name        = 'observability.logging'
metadata description = 'Creates a Log Analytics workspace and an Application Insights component bound to it'

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('Log Analytics workspace name')
param logAnalyticsName string

@description('Application Insights component name')
param appInsightsName string

@description('Log Analytics workspace SKU name')
param workspaceSku string = 'PerGB2018'

@description('Log retention in days (7-730)')
param retentionInDays int = 30

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: workspaceSku
    }
    retentionInDays: retentionInDays
  }
}

// Application Insights (workspace-based)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output logAnalyticsId string = logAnalytics.id
// NOTE: Treat as sensitive; do not output from root template
output appInsightsConnectionString string = appInsights.properties.ConnectionString

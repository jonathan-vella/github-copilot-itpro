// ============================================================================
// Monitoring Module - Log Analytics Workspace and Application Insights
// ============================================================================
// Purpose: Deploys centralized monitoring and logging infrastructure
// Phase: 2 - Platform Services

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var logAnalyticsWorkspaceName = 'log-${projectName}-${environment}'
var applicationInsightsName = 'appi-${projectName}-${environment}'

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'log-analytics-deployment'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    skuName: 'PerGB2018'
    dataRetention: 90
    dailyQuotaGb: 5
  }
}

// ============================================================================
// APPLICATION INSIGHTS
// ============================================================================

module applicationInsights 'br/public:avm/res/insights/component:0.7.0' = {
  name: 'app-insights-deployment'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    kind: 'web'
    applicationType: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Log Analytics Workspace resource ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.resourceId

@description('Log Analytics Workspace name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name

@description('Application Insights resource ID')
output applicationInsightsId string = applicationInsights.outputs.resourceId

@description('Application Insights name')
output applicationInsightsName string = applicationInsights.outputs.name

@description('Application Insights instrumentation key')
@secure()
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey

@description('Application Insights connection string')
@secure()
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString

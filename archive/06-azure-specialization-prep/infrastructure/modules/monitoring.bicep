// monitoring.bicep - Monitoring and Observability Module
// Purpose: Deploys Log Analytics, Application Insights, and Action Groups

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

@description('Log Analytics workspace retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Log Analytics workspace daily quota in GB')
@minValue(1)
@maxValue(10)
param dailyQuotaGb int = 5

@description('Email addresses for alert notifications')
param alertEmailAddresses array

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var workspaceName = 'log-taskmanager-${environment}-${location}'
var appInsightsName = 'appi-taskmanager-${environment}-${location}'
var actionGroupName = 'ag-taskmanager-ops-${environment}'
var actionGroupShortName = 'tm-ops'

// ============================================
// RESOURCES
// ============================================

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Application Insights (workspace-based)
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: retentionInDays
    SamplingPercentage: environment == 'prod' ? 50 : 100
  }
}

// Action Group for Alerts
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: tags
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: [for (email, i) in alertEmailAddresses: {
      name: 'Email-${i}'
      emailAddress: email
      useCommonAlertSchema: true
    }]
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('Log Analytics workspace resource ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

@description('Log Analytics workspace name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

@description('Application Insights resource ID')
output applicationInsightsId string = applicationInsights.id

@description('Application Insights instrumentation key')
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights connection string')
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString

@description('Action group resource ID')
output actionGroupId string = actionGroup.id

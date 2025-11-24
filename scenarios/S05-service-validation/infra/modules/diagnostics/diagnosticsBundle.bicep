// Module: diagnostics.diagnosticsBundle (SAIF v2)
// Purpose: Attach diagnostic settings for API App Service, Web App Service, and SQL Server in one module.
// Replaces individual siteDiagnostics/sqlDiagnostics modules (Option B consolidation).
// EDUCATIONAL NOTE: Broad log categories enabled for training visibility.
// TODO (Secure Alternative): Tune categories; add retention policies & threat detection.

metadata name        = 'diagnostics.bundle'
metadata description = 'Composite diagnostic settings for API site, Web site, and SQL server'
metadata version     = '1.0.0'
metadata owner       = 'SAIF Team'
metadata lastUpdated = '2025-09-04'

@description('API App Service name')
param apiSiteName string

@description('Web App Service name')
param webSiteName string

@description('SQL Server name')
param sqlServerName string

@description('Log Analytics workspace resource ID')
param workspaceId string

@description('Unique suffix used in naming pattern')
param uniqueSuffix string

@description('App Service log categories to enable')
param siteLogCategories array = [ 'AppServiceHTTPLogs', 'AppServiceConsoleLogs' ]

@description('Enable App Service metrics collection')
param enableSiteMetrics bool = true

@description('Enable SQL server metrics collection')
param enableSqlMetrics bool = true

// Existing resources
resource apiSite 'Microsoft.Web/sites@2023-01-01' existing = { name: apiSiteName }
resource webSite 'Microsoft.Web/sites@2023-01-01' existing = { name: webSiteName }
resource sqlSrv  'Microsoft.Sql/servers@2023-05-01-preview' existing = { name: sqlServerName }

// Diagnostics resources (names match original inline pattern to minimize churn)
resource apiDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ds-api-v2-${uniqueSuffix}'
  scope: apiSite
  properties: {
    workspaceId: workspaceId
    logs: [for c in siteLogCategories: { category: c, enabled: true }]
    metrics: enableSiteMetrics ? [ { category: 'AllMetrics', enabled: true } ] : []
  }
}

resource webDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ds-web-v2-${uniqueSuffix}'
  scope: webSite
  properties: {
    workspaceId: workspaceId
    logs: [for c in siteLogCategories: { category: c, enabled: true }]
    metrics: enableSiteMetrics ? [ { category: 'AllMetrics', enabled: true } ] : []
  }
}

resource sqlDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ds-sql-v2-${uniqueSuffix}'
  scope: sqlSrv
  properties: {
    workspaceId: workspaceId
    metrics: enableSqlMetrics ? [ { category: 'AllMetrics', enabled: true } ] : []
  }
}

output apiDiagnosticsId string = apiDiag.id
output webDiagnosticsId string = webDiag.id
output sqlDiagnosticsId string = sqlDiag.id

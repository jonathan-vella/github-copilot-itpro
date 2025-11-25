// Module: diagnostics.siteDiagnostics (SAIF v2)
// Purpose: Attach diagnostic settings for an App Service (Linux) to Log Analytics.
// EDUCATIONAL NOTE: Logs broadly enabled for training visibility.
// TODO (Secure Alternative): Limit categories to least privilege; add retention policies via Log Analytics.

metadata name        = 'diagnostics.siteDiagnostics'
metadata description = 'Diagnostic settings for an App Service to Log Analytics'
metadata version     = '1.0.0'
metadata owner       = 'SAIF Team'
metadata lastUpdated = '2025-09-04'

@description('App Service site name')
param siteName string

@description('Log Analytics workspace resource ID')
param workspaceId string

@description('Unique suffix for deterministic naming (align with root)')
param uniqueSuffix string

@description('Log categories to enable')
param logCategories array = [ 'AppServiceHTTPLogs', 'AppServiceConsoleLogs' ]

@description('Enable metrics category AllMetrics')
param enableMetrics bool = true

var diagName = 'ds-${siteName}-${uniqueSuffix}'

resource site 'Microsoft.Web/sites@2023-01-01' existing = { name: siteName }

resource siteDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagName
  scope: site
  properties: {
    workspaceId: workspaceId
    logs: [for c in logCategories: {
      category: c
      enabled: true
    }]
    metrics: enableMetrics ? [ { category: 'AllMetrics', enabled: true } ] : []
  }
}

output id string = siteDiag.id

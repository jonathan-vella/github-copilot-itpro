// Module: diagnostics.sqlDiagnostics (SAIF v2)
// Purpose: Attach diagnostic settings for a SQL logical server to Log Analytics.
// EDUCATIONAL NOTE: Metrics only (baseline) for training; broad logging could be added.
// TODO (Secure Alternative): Add auditing & threat detection to storage / Log Analytics; restrict categories per compliance.

metadata name        = 'diagnostics.sqlDiagnostics'
metadata description = 'Diagnostic settings for a SQL Server to Log Analytics'
metadata version     = '1.0.0'
metadata owner       = 'SAIF Team'
metadata lastUpdated = '2025-09-04'

@description('SQL logical server name')
param serverName string

@description('Log Analytics workspace resource ID')
param workspaceId string

@description('Unique suffix for deterministic naming (align with root)')
param uniqueSuffix string

@description('Enable metrics collection (AllMetrics)')
param enableMetrics bool = true

var diagName = 'ds-sql-${uniqueSuffix}'

resource sqlSrv 'Microsoft.Sql/servers@2023-05-01-preview' existing = { name: serverName }

resource sqlDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagName
  scope: sqlSrv
  properties: {
    workspaceId: workspaceId
    metrics: enableMetrics ? [ { category: 'AllMetrics', enabled: true } ] : []
  }
}

output id string = sqlDiag.id

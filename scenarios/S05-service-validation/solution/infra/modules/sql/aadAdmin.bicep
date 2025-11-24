// Module: sql.aadAdmin (SAIF v2)
// Purpose: Configure Azure AD admin on a SQL logical server to enable EXTERNAL PROVIDER users.
// EDUCATIONAL NOTE: This keeps broad admin assignment for training. 
// TODO (Secure Alternative): Assign a least-privilege group as admin; restrict public access with Private Endpoint.

metadata name        = 'sql.aadAdmin'
metadata description = 'Sets Azure AD administrator for a SQL logical server (training baseline)'
metadata version     = '1.0.0'
metadata owner       = 'SAIF Team'
metadata lastUpdated = '2025-09-04'

@description('SQL logical server name')
param serverName string

@description('Azure AD admin login (user or group display name)')
param login string

@description('Azure AD objectId (GUID) for user or group')
@minLength(36)
@maxLength(36)
param objectId string

@description('Tenant ID (defaults to current)')
param tenantId string = tenant().tenantId

// Existing server reference
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: serverName
}

// Administrator assignment
resource sqlAadAdmin 'Microsoft.Sql/servers/administrators@2023-05-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: login
    sid: objectId
    tenantId: tenantId
  }
}

// No outputs needed; presence of resource is sufficient.

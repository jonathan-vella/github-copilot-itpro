// SQL module: Logical SQL Server with Entra ID-only authentication
metadata name = 'sql.server'
metadata description = 'Creates a SQL logical server with Entra ID-only authentication enabled'

@description('Server name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('Administrator login username (kept for compatibility but not used with Entra-only auth)')
param administratorLogin string

@secure()
@description('Administrator login password (kept for compatibility but not used with Entra-only auth)')
param administratorLoginPassword string

@description('Azure AD admin login (user or group display name)')
param aadAdminLogin string

@description('Azure AD objectId (GUID) for user or group')
param aadAdminObjectId string

@description('Tenant ID (defaults to current)')
param tenantId string = tenant().tenantId

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: aadAdminLogin
      sid: aadAdminObjectId
      tenantId: tenantId
    }
  }
}

output id string = sqlServer.id
output name string = sqlServer.name
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

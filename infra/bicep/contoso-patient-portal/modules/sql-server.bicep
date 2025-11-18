// ============================================================================
// SQL Server Module - Logical Database Server
// ============================================================================
// Purpose: Deploys Azure SQL logical server with security configurations
// Phase: 2 - Platform Services

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('SQL administrator username')
param sqlAdminUsername string

@description('SQL administrator password')
@secure()
param sqlAdminPassword string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var sqlServerName = 'sql-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'

// ============================================================================
// SQL SERVER
// ============================================================================

module sqlServer 'br/public:avm/res/sql/server:0.21.0' = {
  name: 'sql-server-deployment'
  params: {
    name: sqlServerName
    location: location
    tags: tags
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('SQL Server resource ID')
output sqlServerId string = sqlServer.outputs.resourceId

@description('SQL Server name')
output sqlServerName string = sqlServer.outputs.name

@description('SQL Server fully qualified domain name')
output fullyQualifiedDomainName string = sqlServer.outputs.fullyQualifiedDomainName

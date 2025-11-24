// SQL module: Database
metadata name        = 'sql.database'
metadata description = 'Creates a database on a SQL logical server'

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('SQL server name (parent)')
param serverName string

@description('Database name')
param name string

@description('SKU name (e.g., S1)')
param skuName string = 'S1'

@description('SKU tier (e.g., Standard)')
param skuTier string = 'Standard'

@description('Database collation')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  name: '${serverName}/${name}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    collation: collation
  }
}

output id string = sqlDatabase.id
output dbName string = sqlDatabase.name

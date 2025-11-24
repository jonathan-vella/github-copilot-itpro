// SQL module: Firewall rule 0.0.0.0 (Allow Azure services) for SAIF training
metadata name        = 'sql.firewallAllowAzure'
metadata description = 'Creates the AllowAzureServices firewall rule (0.0.0.0) on a SQL logical server'

@description('SQL server name (parent)')
param serverName string

@description('Firewall rule name')
param name string = 'AllowAzureServices'

resource rule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  name: '${serverName}/${name}'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output id string = rule.id
output ruleName string = rule.name

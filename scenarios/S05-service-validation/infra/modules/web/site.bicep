// Web module: Linux Web App (container)
metadata name        = 'web.site'
metadata description = 'Creates a Linux App Service configured for a container image'

@description('Site name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('App Service Plan resource ID')
param serverFarmId string

@description('Container image (e.g., myacr.azurecr.io/repo:tag)')
param image string

@description('WEBSITES_PORT value (e.g., 8000 for API)')
param websitesPort string = '80'

@description('Health check path (e.g., /api/healthcheck)')
param healthCheckPath string = '/'

@description('Additional app settings')
param appSettings array = []

resource site 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarmId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${image}'
      alwaysOn: true
      acrUseManagedIdentityCreds: true
  minTlsVersion: '1.2'
      healthCheckPath: healthCheckPath
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: websitesPort
        }
        ...appSettings
      ]
    }
  }
}

output id string = site.id
output name string = site.name
output defaultHostName string = site.properties.defaultHostName
output principalId string = site.identity.principalId

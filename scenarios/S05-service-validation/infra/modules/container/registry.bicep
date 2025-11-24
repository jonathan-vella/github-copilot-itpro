// Container module: Azure Container Registry
metadata name        = 'container.registry'
metadata description = 'Creates an Azure Container Registry'

@description('Registry name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('ACR SKU')
param skuName string = 'Standard'

@description('Enable admin user (disable by default)')
param adminUserEnabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output id string = acr.id
output name string = acr.name
output loginServer string = acr.properties.loginServer

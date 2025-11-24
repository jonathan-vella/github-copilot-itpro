// Web module: App Service Plan (Linux)
metadata name        = 'web.plan'
metadata description = 'Creates a Linux App Service Plan'

@description('Plan name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object = {}

@description('SKU name (e.g., P1v3)')
param skuName string = 'P1v3'

@description('SKU tier (e.g., PremiumV3)')
param skuTier string = 'PremiumV3'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name

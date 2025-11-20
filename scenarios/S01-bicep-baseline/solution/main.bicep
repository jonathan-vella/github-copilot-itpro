// =============================================================================
// MAIN.BICEP - Main Orchestration Template
// =============================================================================
// This is the main entry point for deploying the complete infrastructure.
// It orchestrates the deployment of network and storage resources.
//
// Components:
// - Network infrastructure (VNet, subnets, NSGs)
// - Storage infrastructure (Storage account, blob services)
//
// Usage:
//   az deployment group create \
//     --resource-group rg-demo \
//     --template-file main.bicep \
//     --parameters environment=dev location=eastus
//
// Generated with GitHub Copilot assistance
// =============================================================================

// =============================================================================
// PARAMETERS
// =============================================================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
  'demo'
])
param environment string = 'dev'

@description('Name of the virtual network')
param vnetName string = 'vnet-${environment}-demo'

@description('Address space for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('Storage account name (must be globally unique, 3-24 characters, lowercase and numbers only)')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'st${environment}${uniqueString(resourceGroup().id)}'

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageSku string = 'Standard_LRS'

@description('Enable public network access to storage (should be false for production)')
param allowPublicStorageAccess bool = false

@description('Common tags for all resources')
param tags object = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'GitHub-Copilot-Demo'
  DeployedBy: 'GitHub-Copilot'
  Repository: 'github-copilot-itpro'
}

// =============================================================================
// MODULE: NETWORK INFRASTRUCTURE
// =============================================================================

module network 'network.bicep' = {
  name: 'network-deployment-${environment}'
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: addressPrefix
    environment: environment
    tags: tags
  }
}

// =============================================================================
// MODULE: STORAGE INFRASTRUCTURE
// =============================================================================

module storage 'storage.bicep' = {
  name: 'storage-deployment-${environment}'
  params: {
    location: location
    storageAccountName: storageAccountName
    environment: environment
    storageSku: storageSku
    accessTier: 'Hot'
    softDeleteRetentionDays: 7
    allowPublicAccess: allowPublicStorageAccess
    tags: tags
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Deployment summary')
output deploymentSummary object = {
  environment: environment
  location: location
  resourceGroup: resourceGroup().name
  deploymentName: deployment().name
}

@description('Network infrastructure outputs')
output network object = {
  vnetId: network.outputs.vnetId
  vnetName: network.outputs.vnetName
  subnets: network.outputs.subnets
  nsgIds: network.outputs.nsgIds
}

@description('Storage infrastructure outputs')
output storage object = {
  storageAccountId: storage.outputs.storageAccountId
  storageAccountName: storage.outputs.storageAccountName
  blobEndpoint: storage.outputs.blobEndpoint
  fileEndpoint: storage.outputs.fileEndpoint
  properties: storage.outputs.storageProperties
}

@description('Quick reference URLs')
output azurePortalUrls object = {
  resourceGroup: 'https://portal.azure.com/#@/resource${resourceGroup().id}'
  vnet: 'https://portal.azure.com/#@/resource${network.outputs.vnetId}'
  storage: 'https://portal.azure.com/#@/resource${storage.outputs.storageAccountId}'
}

@description('Next steps and recommendations')
output nextSteps array = [
  'Verify network security group rules in Azure Portal'
  'Test connectivity between subnet tiers'
  'Configure private endpoint for storage account (for production)'
  'Enable diagnostic settings for monitoring'
  'Review and adjust storage access policies'
  'Configure backup and disaster recovery'
]

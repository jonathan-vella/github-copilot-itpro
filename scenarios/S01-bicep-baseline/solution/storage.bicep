// =============================================================================
// STORAGE.BICEP - Secure Azure Storage Account
// =============================================================================
// This Bicep template creates a secure storage account configured for
// enterprise use with blob storage, security hardening, and compliance features.
//
// Components:
// - Storage account with secure defaults
// - Blob service with soft delete
// - Network access restrictions
// - Encryption and TLS settings
//
// Generated with GitHub Copilot assistance
// =============================================================================

// =============================================================================
// PARAMETERS
// =============================================================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Storage account name (must be globally unique, 3-24 characters, lowercase letters and numbers only)')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stdemo${uniqueString(resourceGroup().id)}'

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
  'demo'
])
param environment string = 'dev'

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageSku string = 'Standard_LRS'

@description('Storage account access tier')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Number of days to retain soft-deleted blobs')
@minValue(1)
@maxValue(365)
param softDeleteRetentionDays int = 7

@description('Enable public network access (should be disabled for production)')
param allowPublicAccess bool = false

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'GitHub-Copilot-Demo'
}

// =============================================================================
// STORAGE ACCOUNT
// =============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    // Access tier for blob storage
    accessTier: accessTier

    // Security settings
    supportsHttpsTrafficOnly: true // Enforce HTTPS
    minimumTlsVersion: 'TLS1_2' // Require TLS 1.2 or higher
    allowBlobPublicAccess: false // Disable anonymous blob access
    allowSharedKeyAccess: true // Allow access keys (can be disabled for AAD-only)

    // Network access
    publicNetworkAccess: allowPublicAccess ? 'Enabled' : 'Disabled'

    // Default network rules (deny by default if public access disabled)
    networkAcls: {
      defaultAction: allowPublicAccess ? 'Allow' : 'Deny'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }

    // Encryption
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
    }
  }
}

// =============================================================================
// BLOB SERVICE CONFIGURATION
// =============================================================================

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    // Soft delete for blobs
    deleteRetentionPolicy: {
      enabled: true
      days: softDeleteRetentionDays
    }

    // Soft delete for containers
    containerDeleteRetentionPolicy: {
      enabled: true
      days: softDeleteRetentionDays
    }

    // Versioning (optional, can enable for audit trail)
    isVersioningEnabled: false

    // Change feed (for monitoring blob changes)
    changeFeed: {
      enabled: false
    }
  }
}

// =============================================================================
// DEFAULT BLOB CONTAINER (Optional)
// =============================================================================

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'appdata'
  properties: {
    publicAccess: 'None' // No anonymous access
    metadata: {
      purpose: 'Application data storage'
      environment: environment
    }
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Resource ID of the storage account')
output storageAccountId string = storageAccount.id

@description('Name of the storage account')
output storageAccountName string = storageAccount.name

@description('Primary blob endpoint')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('Primary file endpoint')
output fileEndpoint string = storageAccount.properties.primaryEndpoints.file

@description('Storage account properties summary')
output storageProperties object = {
  name: storageAccount.name
  location: storageAccount.location
  sku: storageAccount.sku.name
  httpsOnly: storageAccount.properties.supportsHttpsTrafficOnly
  minTlsVersion: storageAccount.properties.minimumTlsVersion
  publicAccess: storageAccount.properties.publicNetworkAccess
  accessTier: storageAccount.properties.accessTier
}

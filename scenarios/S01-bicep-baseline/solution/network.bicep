// =============================================================================
// NETWORK.BICEP - Azure Virtual Network with Three-Tier Architecture
// =============================================================================
// This Bicep template creates a secure three-tier network infrastructure
// suitable for enterprise applications requiring network segmentation.
//
// Components:
// - Virtual Network with /16 address space
// - Three subnets (Web, App, Data tiers)
// - Network Security Groups for each tier
// - Security rules implementing least-privilege access
//
// Generated with GitHub Copilot assistance
// =============================================================================

// =============================================================================
// PARAMETERS
// =============================================================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Name of the virtual network')
param vnetName string = 'vnet-demo'

@description('Address space for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
  'demo'
])
param environment string = 'dev'

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'GitHub-Copilot-Demo'
}

// =============================================================================
// NETWORK SECURITY GROUPS
// =============================================================================

// NSG for Web Tier - Allows inbound HTTP/HTTPS from Internet
resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-web-${environment}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          description: 'Allow HTTP traffic from Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '10.0.1.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          description: 'Allow HTTPS traffic from Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '10.0.1.0/24'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-To-AppTier'
        properties: {
          description: 'Allow traffic from Web to App tier'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.2.0/24'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// NSG for App Tier - Allows inbound from Web Tier only
resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-app-${environment}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-From-WebTier'
        properties: {
          description: 'Allow traffic from Web tier'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.2.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-To-DataTier'
        properties: {
          description: 'Allow traffic from App to Data tier'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '10.0.3.0/24'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// NSG for Data Tier - Allows inbound from App Tier only
resource nsgData 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-data-${environment}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-From-AppTier'
        properties: {
          description: 'Allow SQL traffic from App tier'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '10.0.3.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// =============================================================================
// VIRTUAL NETWORK
// =============================================================================

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-web-${environment}'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgWeb.id
          }
        }
      }
      {
        name: 'snet-app-${environment}'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsgApp.id
          }
        }
      }
      {
        name: 'snet-data-${environment}'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: {
            id: nsgData.id
          }
        }
      }
    ]
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Resource ID of the virtual network')
output vnetId string = virtualNetwork.id

@description('Name of the virtual network')
output vnetName string = virtualNetwork.name

@description('Resource IDs of the Network Security Groups')
output nsgIds object = {
  web: nsgWeb.id
  app: nsgApp.id
  data: nsgData.id
}

@description('Subnet details for reference')
output subnets object = {
  web: {
    name: 'snet-web-${environment}'
    addressPrefix: '10.0.1.0/24'
    id: virtualNetwork.properties.subnets[0].id
  }
  app: {
    name: 'snet-app-${environment}'
    addressPrefix: '10.0.2.0/24'
    id: virtualNetwork.properties.subnets[1].id
  }
  data: {
    name: 'snet-data-${environment}'
    addressPrefix: '10.0.3.0/24'
    id: virtualNetwork.properties.subnets[2].id
  }
}

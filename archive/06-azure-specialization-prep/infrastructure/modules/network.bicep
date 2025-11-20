// network.bicep - Network Infrastructure Module
// Purpose: Deploys VNet, subnets, NSGs, and public IP for Contoso Task Manager
// ALZ Alignment: Network topology, security, resource organization

targetScope = 'resourceGroup'

// ============================================
// PARAMETERS
// ============================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('Virtual network address space (CIDR notation)')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Web tier subnet address prefix (CIDR notation)')
param webSubnetPrefix string = '10.0.1.0/24'

@description('Data tier subnet address prefix (CIDR notation)')
param dataSubnetPrefix string = '10.0.2.0/24'

@description('Corporate network CIDR for management access (RDP, SQL)')
param corporateNetworkCidr string = '203.0.113.0/24'

@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var vnetName = 'vnet-taskmanager-${environment}-${location}'
var webSubnetName = 'snet-web-${environment}'
var dataSubnetName = 'snet-data-${environment}'
var webNsgName = 'nsg-web-${environment}'
var dataNsgName = 'nsg-data-${environment}'
var publicIpName = 'pip-lb-taskmanager-${environment}'
var dnsLabel = 'taskmanager-${environment}-${uniqueString(resourceGroup().id)}'

// ============================================
// RESOURCES
// ============================================

// Network Security Group - Web Tier
resource webNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: webNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      // Inbound Rules
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          description: 'Allow HTTP traffic from Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: webSubnetPrefix
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
          destinationAddressPrefix: webSubnetPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-RDP-Corporate'
        properties: {
          description: 'Allow RDP from corporate network for management'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: corporateNetworkCidr
          destinationAddressPrefix: webSubnetPrefix
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny all other inbound traffic (default deny)'
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
      // Outbound Rules
      {
        name: 'Allow-HTTP-Outbound'
        properties: {
          description: 'Allow HTTP outbound for Windows Updates'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: webSubnetPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow-HTTPS-Outbound'
        properties: {
          description: 'Allow HTTPS outbound for Windows Updates'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: webSubnetPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow-SQL-To-Data-Subnet'
        properties: {
          description: 'Allow SQL traffic to data tier subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: webSubnetPrefix
          destinationAddressPrefix: dataSubnetPrefix
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Network Security Group - Data Tier
resource dataNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: dataNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      // Inbound Rules
      {
        name: 'Allow-SQL-From-Web-Subnet'
        properties: {
          description: 'Allow SQL traffic from web tier only'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: webSubnetPrefix
          destinationAddressPrefix: dataSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-SQL-Corporate'
        properties: {
          description: 'Allow SQL from corporate network for management'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: corporateNetworkCidr
          destinationAddressPrefix: dataSubnetPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny all other inbound traffic (default deny)'
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

// Virtual Network with Subnets
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: webSubnetPrefix
          networkSecurityGroup: {
            id: webNsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
          ]
        }
      }
      {
        name: dataSubnetName
        properties: {
          addressPrefix: dataSubnetPrefix
          networkSecurityGroup: {
            id: dataNsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
          ]
        }
      }
    ]
  }
}

// Public IP Address for Load Balancer
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabel
    }
    idleTimeoutInMinutes: 4
  }
}

// Diagnostic Settings for Web NSG
resource webNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${webNsgName}-diagnostics'
  scope: webNsg
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Diagnostic Settings for Data NSG
resource dataNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${dataNsgName}-diagnostics'
  scope: dataNsg
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('Virtual network resource ID')
output vnetId string = vnet.id

@description('Virtual network name')
output vnetName string = vnet.name

@description('Web tier subnet resource ID')
output webSubnetId string = vnet.properties.subnets[0].id

@description('Data tier subnet resource ID')
output dataSubnetId string = vnet.properties.subnets[1].id

@description('Web tier NSG resource ID')
output webNsgId string = webNsg.id

@description('Data tier NSG resource ID')
output dataNsgId string = dataNsg.id

@description('Public IP resource ID')
output publicIpId string = publicIp.id

@description('Public IP address (static)')
output publicIpAddress string = publicIp.properties.ipAddress

@description('Public IP DNS FQDN')
output publicIpFqdn string = publicIp.properties.dnsSettings.fqdn

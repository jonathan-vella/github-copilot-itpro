// loadbalancer.bicep - Load Balancer Infrastructure Module
// Purpose: Deploys Azure Load Balancer with backend pool and health probes

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

@description('Public IP resource ID')
param publicIpId string

@description('Array of network interface resource IDs')
param networkInterfaceIds array

@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var loadBalancerName = 'lb-web-${environment}'
var frontendIpConfigName = 'fe-config'
var backendPoolName = 'be-pool-web'
var healthProbeName = 'health-probe-http'
var lbRuleHttpName = 'lb-rule-http'
var lbRuleHttpsName = 'lb-rule-https'

// ============================================
// RESOURCES
// ============================================

// Azure Load Balancer (Standard SKU)
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-05-01' = {
  name: loadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIpConfigName
        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: lbRuleHttpName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendIpConfigName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, healthProbeName)
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'
        }
      }
      {
        name: lbRuleHttpsName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendIpConfigName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, healthProbeName)
          }
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'
        }
      }
    ]
  }
}

// Update Network Interfaces to add to backend pool
resource networkInterfaceUpdate 'Microsoft.Network/networkInterfaces@2023-05-01' = [for (nicId, i) in networkInterfaceIds: {
  name: last(split(nicId, '/'))
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: reference(nicId, '2023-05-01').ipConfigurations[0].properties.subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancer.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}]

// Diagnostic Settings for Load Balancer
resource loadBalancerDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${loadBalancerName}-diagnostics'
  scope: loadBalancer
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'LoadBalancerAlertEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'LoadBalancerProbeHealthStatus'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
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

@description('Load balancer resource ID')
output loadBalancerId string = loadBalancer.id

@description('Load balancer name')
output loadBalancerName string = loadBalancer.name

@description('Backend address pool resource ID')
output backendPoolId string = loadBalancer.properties.backendAddressPools[0].id

@description('Frontend IP configuration resource ID')
output frontendIpConfigId string = loadBalancer.properties.frontendIPConfigurations[0].id

@description('Health probe resource ID')
output healthProbeId string = loadBalancer.properties.probes[0].id

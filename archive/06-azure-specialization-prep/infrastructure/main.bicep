// main.bicep - Main Orchestration Template
// Purpose: Deploys complete Contoso Task Manager infrastructure for Azure Specialization audit
// Author: Generated with GitHub Copilot
// Date: November 2025

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

@description('Web tier subnet address prefix')
param webSubnetPrefix string = '10.0.1.0/24'

@description('Data tier subnet address prefix')
param dataSubnetPrefix string = '10.0.2.0/24'

@description('Corporate network CIDR for management access')
param corporateNetworkCidr string = '203.0.113.0/24'

@description('Administrator username for VMs')
param adminUsername string = 'azureadmin'

@description('Administrator password for VMs')
@secure()
param adminPassword string

@description('VM size for web servers')
param vmSize string = 'Standard_D2s_v3'

@description('Number of VMs to deploy')
@minValue(2)
@maxValue(4)
param vmCount int = 2

@description('SQL Server administrator username')
param sqlAdminUsername string = 'sqladmin'

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('SQL Database SKU')
@allowed([
  'Basic'
  'S0'
  'S1'
  'S2'
  'S3'
])
param databaseSku string = 'S2'

@description('Email addresses for alert notifications')
param alertEmailAddresses array = [
  'ops-team@contoso.com'
]

@description('Common tags applied to all resources')
param tags object = {
  Environment: environment
  Project: 'TaskManager'
  ManagedBy: 'Bicep'
  Owner: 'IT-Ops'
  SLA: '99.99%'
  AuditRequired: 'Yes'
  DeploymentDate: utcNow('yyyy-MM-dd')
}

// ============================================
// VARIABLES
// ============================================

var deploymentId = uniqueString(resourceGroup().id, deployment().name)

// ============================================
// MODULE DEPLOYMENTS
// ============================================

// 1. Monitoring Infrastructure (deployed first for diagnostics)
module monitoring 'modules/monitoring.bicep' = {
  name: 'deploy-monitoring-${deploymentId}'
  params: {
    location: location
    environment: environment
    retentionInDays: environment == 'prod' ? 90 : 30
    dailyQuotaGb: environment == 'prod' ? 5 : 1
    alertEmailAddresses: alertEmailAddresses
    tags: tags
  }
}

// 2. Network Infrastructure (VNet, Subnets, NSGs, Public IP)
module network 'modules/network.bicep' = {
  name: 'deploy-network-${deploymentId}'
  params: {
    location: location
    environment: environment
    vnetAddressPrefix: vnetAddressPrefix
    webSubnetPrefix: webSubnetPrefix
    dataSubnetPrefix: dataSubnetPrefix
    corporateNetworkCidr: corporateNetworkCidr
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// 3. Database Infrastructure (Azure SQL Server and Database)
module database 'modules/database.bicep' = {
  name: 'deploy-database-${deploymentId}'
  params: {
    location: location
    environment: environment
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    databaseSku: databaseSku
    webSubnetCidr: webSubnetPrefix
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    network
  ]
}

// 4. Compute Infrastructure (VMs, Availability Set, Extensions)
module compute 'modules/compute.bicep' = {
  name: 'deploy-compute-${deploymentId}'
  params: {
    location: location
    environment: environment
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    vmCount: vmCount
    subnetId: network.outputs.webSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    network
    monitoring
  ]
}

// 5. Load Balancer (depends on compute for backend pool)
module loadbalancer 'modules/loadbalancer.bicep' = {
  name: 'deploy-loadbalancer-${deploymentId}'
  params: {
    location: location
    environment: environment
    publicIpId: network.outputs.publicIpId
    networkInterfaceIds: compute.outputs.networkInterfaceIds
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    compute
  ]
}

// 6. Update Application Insights with alert rules for infrastructure
module alerts 'modules/alerts.bicep' = {
  name: 'deploy-alerts-${deploymentId}'
  params: {
    location: location
    environment: environment
    vmResourceIds: compute.outputs.vmIds
    sqlDatabaseId: database.outputs.databaseId
    loadBalancerId: loadbalancer.outputs.loadBalancerId
    actionGroupId: monitoring.outputs.actionGroupId
    tags: tags
  }
  dependsOn: [
    monitoring
    compute
    database
    loadbalancer
  ]
}

// ============================================
// OUTPUTS
// ============================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Deployment ID for tracking')
output deploymentId string = deploymentId

// Network Outputs
@description('Virtual network resource ID')
output vnetId string = network.outputs.vnetId

@description('Web subnet resource ID')
output webSubnetId string = network.outputs.webSubnetId

@description('Public IP address for load balancer')
output publicIpAddress string = network.outputs.publicIpAddress

@description('Application URL (HTTP)')
output applicationUrl string = 'http://${network.outputs.publicIpAddress}'

// Compute Outputs
@description('VM resource IDs')
output vmIds array = compute.outputs.vmIds

@description('VM names')
output vmNames array = compute.outputs.vmNames

@description('VM private IP addresses')
output vmPrivateIps array = compute.outputs.privateIpAddresses

// Database Outputs
@description('SQL Server fully qualified domain name')
output sqlServerFqdn string = database.outputs.sqlServerFqdn

@description('SQL Database name')
output databaseName string = database.outputs.databaseName

@description('SQL connection string template (add password)')
output connectionStringTemplate string = database.outputs.connectionStringTemplate

// Load Balancer Outputs
@description('Load balancer resource ID')
output loadBalancerId string = loadbalancer.outputs.loadBalancerId

@description('Backend pool resource ID')
output backendPoolId string = loadbalancer.outputs.backendPoolId

// Monitoring Outputs
@description('Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId

@description('Application Insights instrumentation key')
output appInsightsInstrumentationKey string = monitoring.outputs.applicationInsightsInstrumentationKey

@description('Application Insights connection string')
output appInsightsConnectionString string = monitoring.outputs.applicationInsightsConnectionString

// Deployment Summary
@description('Deployment timestamp')
output deploymentTimestamp string = deployment().properties.timestamp

@description('Deployment status message')
output statusMessage string = 'Deployment completed successfully. Access application at: http://${network.outputs.publicIpAddress}'

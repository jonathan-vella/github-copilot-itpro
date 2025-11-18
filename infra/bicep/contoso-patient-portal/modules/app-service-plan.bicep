// ============================================================================
// App Service Plan Module - Compute Capacity
// ============================================================================
// Purpose: Deploys zone-redundant App Service Plan for web application hosting
// Phase: 2 - Platform Services

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var appServicePlanName = 'asp-${projectName}-${environment}'

// ============================================================================
// APP SERVICE PLAN
// ============================================================================

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'app-service-plan-deployment'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    skuCapacity: 2
    skuName: 'S1'
    kind: 'linux'
    zoneRedundant: true
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('App Service Plan resource ID')
output appServicePlanId string = appServicePlan.outputs.resourceId

@description('App Service Plan name')
output appServicePlanName string = appServicePlan.outputs.name

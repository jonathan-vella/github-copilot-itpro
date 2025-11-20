// alerts.bicep - Alert Rules Module
// Purpose: Deploys Azure Monitor alert rules for infrastructure monitoring

targetScope = 'resourceGroup'

// ============================================
// PARAMETERS
// ============================================

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('Array of VM resource IDs to monitor')
param vmResourceIds array

@description('SQL Database resource ID to monitor')
param sqlDatabaseId string

@description('Load Balancer resource ID to monitor')
param loadBalancerId string

@description('Action group resource ID for notifications')
param actionGroupId string

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var alertPrefix = 'alert-${environment}'

// ============================================
// RESOURCES
// ============================================

// VM CPU Alert (for each VM)
resource vmCpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [
  for (vmId, i) in vmResourceIds: {
    name: '${alertPrefix}-vm${i + 1}-cpu-high'
    location: 'global'
    tags: tags
    properties: {
      description: 'Alert when VM CPU usage exceeds 80%'
      severity: 2
      enabled: true
      scopes: [
        vmId
      ]
      evaluationFrequency: 'PT5M'
      windowSize: 'PT15M'
      criteria: {
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
        allOf: [
          {
            name: 'CPU-High'
            metricName: 'Percentage CPU'
            operator: 'GreaterThan'
            threshold: 80
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
      }
      autoMitigate: true
      actions: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
]

// VM Available Memory Alert (for each VM)
resource vmMemoryAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [
  for (vmId, i) in vmResourceIds: {
    name: '${alertPrefix}-vm${i + 1}-memory-low'
    location: 'global'
    tags: tags
    properties: {
      description: 'Alert when VM available memory is less than 1 GB'
      severity: 2
      enabled: true
      scopes: [
        vmId
      ]
      evaluationFrequency: 'PT5M'
      windowSize: 'PT15M'
      criteria: {
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
        allOf: [
          {
            name: 'Memory-Low'
            metricName: 'Available Memory Bytes'
            operator: 'LessThan'
            threshold: 1073741824 // 1 GB in bytes
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
      }
      autoMitigate: true
      actions: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
]

// SQL Database DTU Alert
resource sqlDtuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${alertPrefix}-sql-dtu-high'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when SQL Database DTU consumption exceeds 80%'
    severity: 1
    enabled: true
    scopes: [
      sqlDatabaseId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'DTU-High'
          metricName: 'dtu_consumption_percent'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

// SQL Database Storage Alert
resource sqlStorageAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${alertPrefix}-sql-storage-high'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when SQL Database storage usage exceeds 80%'
    severity: 2
    enabled: true
    scopes: [
      sqlDatabaseId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Storage-High'
          metricName: 'storage_percent'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

// Load Balancer Health Probe Alert
resource lbHealthAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${alertPrefix}-lb-probe-failure'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when Load Balancer health probe availability drops below 100%'
    severity: 0
    enabled: true
    scopes: [
      loadBalancerId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Probe-Failure'
          metricName: 'DipAvailability'
          operator: 'LessThan'
          threshold: 100
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

// Load Balancer SNAT Port Exhaustion Alert
resource lbSnatAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${alertPrefix}-lb-snat-exhaustion'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when SNAT port utilization exceeds 80%'
    severity: 1
    enabled: true
    scopes: [
      loadBalancerId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'SNAT-High'
          metricName: 'UsedSNATPorts'
          operator: 'GreaterThan'
          threshold: 800 // 80% of 1024 default ports
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('Array of VM CPU alert resource IDs')
output vmCpuAlertIds array = [for (vmId, i) in vmResourceIds: vmCpuAlert[i].id]

@description('Array of VM memory alert resource IDs')
output vmMemoryAlertIds array = [for (vmId, i) in vmResourceIds: vmMemoryAlert[i].id]

@description('SQL DTU alert resource ID')
output sqlDtuAlertId string = sqlDtuAlert.id

@description('SQL storage alert resource ID')
output sqlStorageAlertId string = sqlStorageAlert.id

@description('Load balancer health alert resource ID')
output lbHealthAlertId string = lbHealthAlert.id

@description('Load balancer SNAT alert resource ID')
output lbSnatAlertId string = lbSnatAlert.id

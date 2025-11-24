// Security module: Role assignment AcrPull for a principal on a scope
// GUID Salt Realignment: Using subscription + ACR name + principalId for stability across refactors.
// This avoids unintended recreation if resourceId composition changes.
// Previous (transient) variant used guid(acr.id, principalId, 'AcrPull').
// EDUCATIONAL NOTE: Minimal validation for training; real-world module should validate principal format.
// TODO (Secure Alternative): Add parameter to control role; support group/service principal types with validation.
metadata name        = 'security.roleAcrPull'
metadata description = 'Assigns AcrPull role to a principal at a given scope (stable GUID salt)'

@description('Azure Container Registry name (scope for AcrPull)')
param acrName string

@description('Principal (service principal) object ID')
param principalId string

var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = { name: acrName }

resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Stable deterministic GUID not tied to full resourceId to prevent churn on module refactors
  name: guid(subscription().id, acrName, principalId, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output id string = ra.id

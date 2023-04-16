param name string = 'ahkjadf-kv'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: name
  location: location

  properties: {
    sku: { family: 'A', name: 'premium' }
    tenantId: tenant
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

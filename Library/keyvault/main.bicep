param name string = '${uniqueString(resourceGroup().id)}-sa'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    tenantId: tenant
  }
}

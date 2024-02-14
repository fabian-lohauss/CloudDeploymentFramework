param name string = 'a${uniqueString(resourceGroup().id)}-kv'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = { name: name, location: location, properties: { sku: { family: 'A', name: 'premium' }, tenantId: tenant, enableRbacAuthorization: true } }
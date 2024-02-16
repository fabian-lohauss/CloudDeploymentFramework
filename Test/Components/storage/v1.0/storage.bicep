resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'stor${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location, sku: { name: 'Standard_LRS' }, kind: 'StorageV2'
}
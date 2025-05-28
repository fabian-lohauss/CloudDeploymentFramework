    targetScope = 'subscription'
    
    param name string
    param location string = deployment().location
    
    resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = { name: name, location: location }
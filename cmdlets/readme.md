
```pwsh
Initialize-CdfProject -Name "Demo" -Library ../Library -Environment "dev" -CurrentSubscription
New-CdfService -Name "shared" | Add-CdfComponent -Name "KeyVault" -Latest 
Deploy-CdfService "shared" -Environment "dev" -Latest -AllowPreRelease
```

```pwsh
Initialize-CdfProject -Name "Demo"
New-CdfComponent "storage" -Type Bicep | New-Item -Value @'
param location string = resourceGroup().location
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'stor${uniqueString(resourceGroup().id)}'
  location: location, sku: { name: 'Standard_LRS' }, kind: 'StorageV2'
}
'@ | Out-Null

New-CdfServiceTemplate -Name "shared" | Add-CdfComponent "storage" 
Deploy-CdfService "shared" -Version 1.0
```

```pwsh
Initialize-CdfProject | Add-CdfEnvironment "dev" -Subscription (Get-AzSubscription).Id 
New-CdfComponent "keyvault" -Type Bicep | New-Item -Value @"
param name string = 'a${uniqueString(resourceGroup().id)}-kv'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = { name: name, location: location, properties: { sku: { family: 'A', name: 'premium' }, tenantId: tenant } }
"@ | Out-Null

New-CdfServiceTemplate "shared" | Add-CdfComponent "keyvault"

Deploy-CdfService -Name "shared" -Version 1.0

```
# Release Management
```pwsh
# creates version '1.0-PreRelease'
New-CdfServiceTemplate "shared" 

# gets latest pre-release version and removes pre-release flag --> creates version ('1.0', 'latest')
Get-CdfServiceTemplate "shared" -AllowPrerelease | Publish-CdfServiceTemplate 

# gets latest released version and creates new pre-release minor version --> '1.1-PreRelease'
Get-CdfServiceTemplate "shared" | New-CdfServiceTemplate -NewMinorVersion 

# gets latest pre-release version and creates new major version --> '2.0-PreRelease'
Get-CdfServiceTemplate "shared" -AllowPrerelease | New-CdfServiceTemplate -NewMajorVersion 
```

```yaml
# Service template
{
    "Name": "shared",
    "Version": ["latest", "2.13", "2"]
    "Components": [
        "keyvault": "latest",
        "loadbalancer": "3"
    ]
}
```

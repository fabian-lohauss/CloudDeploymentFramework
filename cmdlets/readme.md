
```pwsh
Initialize-DfProject -Name "Demo" -Library ../Library -Environment "dev" -CurrentSubscription
New-DfService -Name "shared" | Add-DfComponent -Name "KeyVault" -Latest 
Deploy-DfService "shared" -Environment "dev" -Latest -AllowPreRelease
```

```pwsh
Initialize-DfProject -Name "Demo" | Add-DfEnvironment -Name "dev" -CurrentSubscription
New-DfComponent "storage" -Type Bicep | New-Item -Value @'
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'stor${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location, sku: { name: 'Standard_LRS' }, kind: 'StorageV2'
}
'@ | Out-Null

New-DfServiceTemplate -Name "shared" | Add-DfComponent "KeyVault" 
Deploy-DfService "shared" -Version 1.0
```

```pwsh
Initialize-DfProject | Add-DfEnvironment "dev" -Subscription (Get-AzSubscription).Id 
New-DfComponent "keyvault" | New-Item -Name "main.bicep" -Value @"
param name string = 'a${uniqueString(resourceGroup().id)}-kv'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = { name: name, location: location, properties: { sku: { family: 'A', name: 'premium' }, tenantId: tenant } }
"@ | Out-Null

New-DfServiceTemplate "shared" | Add-DfComponent "keyvault"

Deploy-DfService -Name "shared" -Version 1.0

```
# Release Management
```pwsh
# creates version '1.0-PreRelease'
New-DfServiceTemplate "shared" 

# gets latest pre-release version and removes pre-release flag --> creates version ('1.0', 'latest')
Get-DfServiceTemplate "shared" -AllowPrerelease | Publish-DfServiceTemplate 

# gets latest released version and creates new pre-release minor version --> '1.1-PreRelease'
Get-DfServiceTemplate "shared" | New-DfServiceTemplate -NewMinorVersion 

# gets latest pre-release version and creates new major version --> '2.0-PreRelease'
Get-DfServiceTemplate "shared" -AllowPrerelease | New-DfServiceTemplate -NewMajorVersion 
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

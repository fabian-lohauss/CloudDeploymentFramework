# DeploymentFramework


```pwsh
Initialize-DfProject
@"
param location string 
resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = { name: '{uniqueString(resourceGroup().id)}-sa', location: location, sku: { name: 'Standard_LRS' }, kind: 'StorageV2' }
"@ | New-DfComponent "keyvault" -Type bicep

@"
param location string 
resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = { name: '{uniqueString(resourceGroup().id)}-sa', location: location, sku: { name: 'Standard_LRS' }, kind: 'StorageV2' }
"@ | New-DfComponent "loadbalancer" -Type bicep
New-DfServiceTemplate "shared" | Add-DfComponent "keyvault", "loadbalancer"

Get-DfServiceTemplate -Type "shared" -Latest -AllowPrerelease | Deploy-DfService 
Get-DfServiceTemplate -Type "workload" -Version 3.1 | Deploy-DfService -StampId 000, 001, 002


```
# Release Management
```pws h
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
{
    "type": "shared",
    "Version": ["latest", "2.13", "2"]
    "Components": [
        "keyvault": "latest",
        "loadbalancer": "3"
    ]
}
```
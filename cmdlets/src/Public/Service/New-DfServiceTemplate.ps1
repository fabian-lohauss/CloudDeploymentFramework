
function New-DfServiceTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ServiceTemplateFolder = Join-Path (Get-DfProject).ServicesPath -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item $ServiceTemplateFolder -ItemType Directory | Out-Null

    $Properties = @{ 
        Name       = $Name; 
        Version    = "1.0-PreRelease";
        PreRelease = $true 
        Path       = $ServiceTemplateFolder
        Component  = (New-Object -TypeName System.Collections.ArrayList)
    }
    $ServiceTemplate = New-Object -TypeName PSCustomObject -Property $Properties

    $ServiceTemplate | Export-DfServiceTemplate

    New-Item $ServiceTemplateFolder -Name ("{0}.bicep" -f $Name) -ItemType File -value @"
    targetScope = 'subscription'
    
    param name string
    param location string = deployment().location
    
    resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = { name: name, location: location }
"@ | Out-Null

    return $ServiceTemplate
}

function Deploy-DfService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, Position = 1)]
        [string]$Version
    )

    Write-Verbose ("Deploying service {0} v{1}" -f $Name, $Version)

    $ProjectConfiguration = Get-DfProject 
    $ServiceFolder = Join-Path $ProjectConfiguration.ServicesPath -ChildPath $Name -AdditionalChildPath ("v{0}" -f $Version)

    $Self = Import-DfServiceTemplate -Path $ServiceFolder

    $ServiceTemplate = Join-Path $ServiceFolder -ChildPath "$Name.bicep" 
    New-AzDeployment -TemplateFile $ServiceTemplate -Location "westeurope" -TemplateParameterObject @{ Name = ("{0}-rg" -f $Name) } | Out-Null

    $Components = $Self | Select-Object -ExpandProperty Component
    foreach ($Component in $Components) {
        Deploy-DfComponent -Name $Component.Name -Version $Component.Version -ResourceGroupName ("{0}-rg" -f $Name)
    }
    Write-Verbose ("Service {0} v{1} deployed" -f $Name, $Version)
}
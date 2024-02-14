
Function Deploy-DfComponent {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName
    )

    Write-Verbose ("Deploying component {0} v{1} to resource group {2}" -f $Name, $Version, $ResourceGroupName)
    $ProjectConfiguration = Get-DfProject 
    $ComponentFolder = Join-Path $ProjectConfiguration.ComponentsPath -ChildPath $Name -AdditionalChildPath ("v{0}" -f $Version)
    $ComponentBicepFile = Join-Path $ComponentFolder -ChildPath ("{0}.bicep" -f $Name)
    if (-not (Test-Path $ComponentBicepFile)) {
        throw ("Failed to find component bicep file '{0}'" -f $ComponentBicepFile)
    }
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $ComponentBicepFile | Out-Null
    Write-Verbose ("Component {0} v{1} deployed to resource group {2}" -f $Name, $Version, $ResourceGroupName)
}

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
    $ComponentTemplate = Get-ChildItem $ComponentFolder -Filter "main.bicep"
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $ComponentTemplate.FullName | Out-Null
    Write-Verbose ("Component {0} v{1} deployed to resource group {2}" -f $Name, $Version, $ResourceGroupName)
}
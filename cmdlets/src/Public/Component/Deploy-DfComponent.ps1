
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
    try {
        $Component = Get-DfComponent -Name $Name -Version $Version
        New-AzResourceGroupDeploymentStack -Name $Name -ResourceGroupName $ResourceGroupName -TemplateFile $Component.Path -DenySettingsMode DenyDelete | Out-Null
        Write-Verbose ("Component {0} v{1} deployed to resource group {2}" -f $Name, $Version, $ResourceGroupName)
    }
    catch {
        throw ("Failed to deploy component '{0}' in version '{1}': {2}" -f $Name, $Version, $_.Exception.Message)
    }
}
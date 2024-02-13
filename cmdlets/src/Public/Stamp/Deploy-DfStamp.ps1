

function Deploy-DfStamp {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name
    )

    New-AzDeployment -Location "weu" -TemplateFile "ResourceGroup.bicep"
}

Function Write-CdfLog {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'StartGroup', Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Message,

        [Parameter(ParameterSetName = 'StartGroup', Mandatory = $true)]
        [switch]$StartGroup,

        [Parameter(ParameterSetName = 'EndGroup', Mandatory = $true)]
        [switch]$EndGroup
    )

    if (Test-CdfDeploymentPipeline) {
        if ($StartGroup) {
            $Message = "##[group]" + $Message
        }
        elseif ($EndGroup) {
            $Message = "##[endgroup]"
        } 
    } else {
        if ($EndGroup) {
            return
        }
    }
    Write-Host $Message

}

function Add-CdfComponent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Position = 0)]
        [string]$Name
    )
    Write-Verbose ("Adding component {0} to service template {1}" -f $Name, $Path)
    $Component = Get-CdfComponent $Name
    $ServiceTemplate = Import-CdfServiceTemplate -Path $Path
    $ServiceTemplate.Component += @([PSCustomObject]@{ Name = $Component.Name; Version = $Component.Version })
    Export-CdfServiceTemplate -Object $ServiceTemplate
}

function Add-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Position = 0)]
        [string]$Name
    )
    Write-Verbose ("Adding component {0} to service template {1}" -f $Name, $Path)
    $Component = Get-DfComponent $Name
    $ServiceTemplate = Import-DfServiceTemplate -Path $Path
    $ServiceTemplate.Component += @([PSCustomObject]@{ Name = $Component.Name; Version = $Component.Version })
    Export-DfServiceTemplate -Object $ServiceTemplate
}
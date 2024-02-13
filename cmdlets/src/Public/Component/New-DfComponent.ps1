

function New-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $Project = Get-DfProject
    $ComponentFolder = Join-Path $Project.ComponentsPath -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item -Path $ComponentFolder -ItemType Directory | Out-Null
    $Properties = @{ 
        Path       = $ComponentFolder;
        Name       = $Name;
        Version    = "1.0-PreRelease"
        PreRelease = $true
    }
    return New-Object -TypeName PSCustomObject -Property $Properties
        
}
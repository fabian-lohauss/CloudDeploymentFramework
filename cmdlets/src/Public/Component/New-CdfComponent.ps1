

function New-CdfComponent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Type
    )

    $Project = Get-CdfProject
    $ComponentFolder = Join-Path $Project.ComponentsPath -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item -Path $ComponentFolder -ItemType Directory | Out-Null
    switch ($Type) {
        "Bicep" {
            $Extension = "bicep"
        }
        "ARM" {
            $Extension = "json"
        }
    }
    $ComponentFile = Join-Path $ComponentFolder -ChildPath "$Name.$Extension"
    $Properties = @{ 
        Path       = $ComponentFile;
        Name       = $Name;
        Version    = "1.0-PreRelease"
        PreRelease = $true
    }
    return New-Object -TypeName PSCustomObject -Property $Properties
        
}
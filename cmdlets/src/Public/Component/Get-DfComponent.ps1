
function Get-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name
    )

    $Project = Get-DfProject
    $Components = foreach ($ComponentFolder in (Get-ChildItem $Project.ComponentsPath)) {
        if (($ComponentFolder.BaseName -like $Name) -or [string]::IsNullOrEmpty($Name)) {
            foreach ($VersionFolder in (Get-ChildItem $ComponentFolder -Filter "v*")) {
                $Properties = @{ 
                    Name    = $ComponentFolder.BaseName; 
                    Version = ($VersionFolder.BaseName -replace "v", "") 
                    Path    = ($VersionFolder | Get-ChildItem ).FullName
                    Type    = "Bicep"
                }
                New-Object -TypeName PSCustomObject -Property $Properties
            }        
        }
    }
    return $Components
}
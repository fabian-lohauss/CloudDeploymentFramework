
function Get-DfComponent {
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(Position = 0, ParameterSetName = "ByName", Mandatory)]
        [Parameter(Position = 0, ParameterSetName = "ByNameAndVersion", Mandatory)]
        [string]$Name,

        [Parameter(Position = 1, ParameterSetName = "ByNameAndVersion", Mandatory)]
        [string]$Version
    )

    $Project = Get-DfProject
    switch ($PSCmdlet.ParameterSetName) {
        "ByName" {
            $Components = foreach ($ComponentFolder in (Get-ChildItem $Project.ComponentsPath)) {
                if (($ComponentFolder.BaseName -eq $Name) -or [string]::IsNullOrEmpty($Name)) {
                    foreach ($VersionFolder in (Get-ChildItem $ComponentFolder -Filter "v*")) {
                        $VersionFromFolder = ($VersionFolder.BaseName -replace "v", "") 
                        $Properties = @{ 
                            Name    = $ComponentFolder.BaseName; 
                            Version = $VersionFromFolder
                            Path    = ($VersionFolder | Get-ChildItem).FullName
                            Type    = "Bicep"
                        }
                        New-Object -TypeName PSCustomObject -Property $Properties
                    }        
                }
            }
        }
        "ByNameAndVersion" {
            $ComponentFolder = Join-Path $Project.ComponentsPath $Name
            $VersionFolder = Join-Path $ComponentFolder "v$Version"
            $Path = Join-Path $VersionFolder "$Name.bicep"

            if (-not (Test-Path $Path)) {
                throw "Failed to find component bicep file '$Path'"
            }
            $Properties = @{ 
                Name    = $Name; 
                Version = $Version
                Path    = $Path
                Type    = "Bicep"
            }
            New-Object -TypeName PSCustomObject -Property $Properties
        }
        "all" {
            $Components = foreach ($ComponentFolder in (Get-ChildItem $Project.ComponentsPath)) {
                foreach ($VersionFolder in (Get-ChildItem $ComponentFolder -Filter "v*")) {
                    $VersionFromFolder = ($VersionFolder.BaseName -replace "v", "") 
                    $Properties = @{ 
                        Name    = $ComponentFolder.BaseName; 
                        Version = $VersionFromFolder
                        Path    = ($VersionFolder | Get-ChildItem ).FullName
                        Type    = "Bicep"
                    }
                    New-Object -TypeName PSCustomObject -Property $Properties
                }
            }        
        }
    }
    return $Components
}
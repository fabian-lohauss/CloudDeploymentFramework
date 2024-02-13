
Function Get-DfProject {
    [CmdletBinding()]
    param ( )

    $Folder = Find-DfProjectFolder
    $Properties = @{ 
        Path           = $Folder.FullName;
        ComponentsPath = Join-Path $Folder.FullName -ChildPath "Components"
        ServicesPath   = Join-Path $Folder.FullName -ChildPath "Services"
    }
    return $Properties
}
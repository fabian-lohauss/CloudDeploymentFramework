
Function Get-CdfProject {
    [CmdletBinding()]
    param ( )

    $Folder = Find-CdfProjectFolder
    $Properties = @{ 
        Path           = $Folder.FullName;
        ComponentsPath = Join-Path $Folder.FullName -ChildPath "Components"
        ServicesPath   = Join-Path $Folder.FullName -ChildPath "Services"
    }
    return $Properties
}
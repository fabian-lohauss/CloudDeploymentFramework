
Function Get-CdfProject {
    [CmdletBinding()]
    param ( )

    $Folder = Find-CdfProjectFolder
    $ConfigurationFile = Join-Path $Folder.FullName -ChildPath ".cdf/Configuration.json"
    $Configuration = Get-Content -Path $ConfigurationFile -Raw | ConvertFrom-Json
    $Properties = @{ 
        Name           = $Configuration.Name;
        Path           = $Folder.FullName;
        ComponentsPath = $Configuration.ComponentsPath;
        ServicesPath   = $Configuration.ServicesPath;
    }
    return New-Object -TypeName PSObject -Property $Properties
}
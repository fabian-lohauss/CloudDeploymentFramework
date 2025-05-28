function Get-CdfServiceTemplate {
    [CmdletBinding()]
    param ( 
        [string]$Name
    )
    
    $ServicesFolder = (Get-CdfProject).ServicesPath
    $Templates = $null
    if (Test-Path $ServicesFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $ServicesFolder -Directory)) {
            if (($Name -eq $Folder.Name) -or ([string]::IsNullOrEmpty($Name))) {
                foreach ($VersionFolder in (Get-ChildItem $Folder -Filter "v*" -Directory)) {
                    Import-CdfServiceTemplate -Path $VersionFolder.FullName
                }
            }
        }
    }
    return $Templates
}

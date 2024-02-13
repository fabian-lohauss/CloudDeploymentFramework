function Get-DfServiceTemplate {
    [CmdletBinding()]
    param ( 
        [string]$Name
    )
    
    $ServicesFolder = (Get-DfProject).ServicesPath
    $Templates = $null
    if (Test-Path $ServicesFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $ServicesFolder -Directory)) {
            if (($Name -eq $Folder.Name) -or ([string]::IsNullOrEmpty($Name))) {
                foreach ($VersionFolder in (Get-ChildItem $Folder -Filter "v*" -Directory)) {
                    Import-DfServiceTemplate -Path $VersionFolder.FullName
                }
            }
        }
    }
    return $Templates
}

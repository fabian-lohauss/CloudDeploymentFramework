
function Get-DfStampTemplate {
    [CmdletBinding()]
    param ( )
    
    $StampFolder = (Get-DfProject).StampFolder
    $Templates = $null
    if (Test-Path $StampFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $StampFolder -Directory)) {
            @{ Name = $Folder.Name } 
        }
    }
    return $Templates
}

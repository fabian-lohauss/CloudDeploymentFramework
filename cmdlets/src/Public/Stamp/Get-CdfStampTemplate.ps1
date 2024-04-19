
function Get-CdfStampTemplate {
    [CmdletBinding()]
    param ( )
    
    $StampFolder = (Get-CdfProject).StampFolder
    $Templates = $null
    if (Test-Path $StampFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $StampFolder -Directory)) {
            @{ Name = $Folder.Name } 
        }
    }
    return $Templates
}

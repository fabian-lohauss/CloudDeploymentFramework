Function Find-CdfProjectFolder {
    [CmdletBinding()]
    [OutputType("System.IO.DirectoryInfo")]
    param ( )

    $CurrentFolder = $pwd
    $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".cdf" | Test-Path 

    while (-not $ProjectFolderFound) {
        $CurrentFolder = Split-Path $CurrentFolder -Parent
        if ([string]::IsNullOrEmpty($CurrentFolder)) {
            throw ("Failed to find CloudDeploymentFramework project folder in '{0}'" -f $pwd)
        }
        $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".cdf" | Test-Path 
    }
    return Get-Item $CurrentFolder
}
Function Find-DfProjectFolder {
    $StartFolder = $pwd
    $CurrentFolder = $StartFolder

    $ProjectFolder = Join-Path $CurrentFolder -ChildPath ".df"
    $ProjectFolderFound = Test-Path $ProjectFolder
    $SearchFailed = $false

    while ((-not $ProjectFolderFound) -and (-not $SearchFailed)) {
        $CurrentFolder = Split-Path $CurrentFolder -Parent
        if ([string]::IsNullOrEmpty($CurrentFolder)) {
            $SearchFailed = $true
            $ProjectFolderFound = $false
        }
        else {
            $ProjectFolder = Join-Path $CurrentFolder -ChildPath ".df"
            $ProjectFolderFound = Test-Path $ProjectFolder
        }
    }

    if ($ProjectFolderFound) {
        return (Resolve-Path $CurrentFolder).Path
    }

    throw ("Failed to find DeploymentFramework project folder in '{0}'" -f $StartFolder)
}
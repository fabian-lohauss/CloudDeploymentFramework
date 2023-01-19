Function Find-DfProjectFolder {
    $CurrentFolder = $pwd
    $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 

    while (-not $ProjectFolderFound) {
        $CurrentFolder = Split-Path $CurrentFolder -Parent
        if ([string]::IsNullOrEmpty($CurrentFolder)) {
            throw ("Failed to find DeploymentFramework project folder in '{0}'" -f $pwd)
        }
        $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 
    }

    return (Resolve-Path $CurrentFolder).Path
}

Function Initialize-DfProject {
    $ProjectFolder = Join-Path $PWD -ChildPath ".df"
    if (-not (Test-Path $ProjectFolder)) {
        New-Item -Path $ProjectFolder -ItemType Directory | Out-Null
    }
}
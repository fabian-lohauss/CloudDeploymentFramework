param(
    [string]$NuGetApiKey
)

$NugetFolder = $PSScriptRoot
Write-Host ("Nuget folder: '{0}'" -f $NugetFolder)

Write-Host ("Creating local nuget repository")
$LocalRepositoryName = "LocalRepository"
$LocalRepositoryPath = Join-Path $NugetFolder -ChildPath "Repository" -AdditionalChildPath $LocalRepositoryName
Write-Host ("Local repository path: '{0}'" -f $LocalRepositoryPath)
New-Item -Path $LocalRepositoryPath -ItemType Directory -Force | Out-Null
if (Get-PSResourceRepository -Name $LocalRepositoryName -ErrorAction SilentlyContinue) {
    Write-Host ("Updating local repository '{0}' with Uri '{1}'" -f $LocalRepositoryName, $LocalRepositoryPath)
    Set-PSResourceRepository -Name $LocalRepositoryName -Uri $LocalRepositoryPath -Trusted
}
else {
    Write-Host ("Registering new local repository '{0}' with Uri '{1}'" -f $LocalRepositoryName, $LocalRepositoryPath)
    Register-PSResourceRepository -Name $LocalRepositoryName -Uri $LocalRepositoryPath -Trusted
}

Write-Host ("Getting module source folder")
$SourceFolder = Join-Path $NugetFolder -ChildPath ../src/CloudDeploymentFramework -Resolve
Write-Host ("Module source folder: '{0}'" -f $SourceFolder)

Write-Host ("Getting folder with public functions")
$PublicFunctionsFolder = Join-Path $SourceFolder -ChildPath "Public" -Resolve
Write-Host ("Public functions folder: '{0}'" -f $PublicFunctionsFolder)

Write-Host ("Getting list of public functions")
$PublicFunctions = @()
$PublicFiles = Get-ChildItem -Path $PublicFunctionsFolder -Recurse -Include *.ps1
foreach ($File in $PublicFiles) {
    $PublicFunctions += @($File.Name -replace ".ps1", "")
}
Write-Host ("Public functions: '{0}'" -f ($PublicFunctions -join "', '"))

Write-Host "Getting latest prerelease version of CloudDeploymentFramework module from PSGallery"
$PublishedModule = Find-PSResource CloudDeploymentFramework -Prerelease -Repository PSGallery
$LatestPrereleaseVersion = $PublishedModule.Version
Write-Host "Latest prerelease version: $LatestPrereleaseVersion"

$NewPrereleaseVersion = [Version]::new($LatestPrereleaseVersion.Major, $LatestPrereleaseVersion.Minor, $LatestPrereleaseVersion.Build + 1)
Write-Host "New prerelease version: $NewPrereleaseVersion"

if (Test-Path Env:GITHUB_STEP_SUMMARY) {
    ("New prerelease version is '{0}'" -f $NewPrereleaseVersion)  | Out-File -FilePath $Env:GITHUB_STEP_SUMMARY -Encoding utf8 -Append
}


$Psd1File = Join-Path $SourceFolder -ChildPath CloudDeploymentFramework.psd1

Update-ModuleManifest -Path $Psd1File -ModuleVersion $NewPrereleaseVersion -CmdletsToExport $PublicFunctions

Write-Host ("Publishing module in version '{0}' to '{1}'" -f $NewPrereleaseVersion, $LocalRepositoryName)
Publish-PSResource -Path $SourceFolder -ApiKey "abc" -Repository $LocalRepositoryName -Verbose

if ([string]::IsNullOrEmpty($NuGetApiKey)) {
    Write-Host ("Skipping publishing to PSGallery because no NuGetApiKey is provided")
}
else {
    Write-Host ("Publishing module in version '{0}' to PSGallery" -f $NewPrereleaseVersion)
    Publish-PSResource -Path $SourceFolder -ApiKey $NuGetApiKey -Repository "PSGallery" -Verbose
}




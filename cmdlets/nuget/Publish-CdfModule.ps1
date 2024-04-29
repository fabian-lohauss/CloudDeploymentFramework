param(
    [Parameter(Mandatory)]
    [string]$NuGetApiKey
)

$NugetFolder = $PSScriptRoot
Write-Host ("Nuget folder: '{0}'" -f $NugetFolder)
Write-Host ("Getting module source folder")
$SourceFolder = Join-Path $NugetFolder -ChildPath ../src/CloudDeploymentFramework -Resolve
Write-Host ("Module source folder: '{0}'" -f $SourceFolder)

Write-Host "Getting latest prerelease version of CloudDeploymentFramework module from PSGallery"
$PublishedModule = Find-PSResource CloudDeploymentFramework -Prerelease -Repository PSGallery
$LatestPrereleaseVersion = $PublishedModule.Version
Write-Host "Latest prerelease version: $LatestPrereleaseVersion"

$NewPrereleaseVersion = [Version]::new($LatestPrereleaseVersion.Major, $LatestPrereleaseVersion.Minor, $LatestPrereleaseVersion.Build + 1)
Write-Host "New version: $NewPrereleaseVersion"

Write-Host ("NEW_VERSION={0}" -f $NewPrereleaseVersion) >> "$env:GITHUB_OUTPUT"


$Psd1File = Join-Path $SourceFolder -ChildPath CloudDeploymentFramework.psd1
$Psd1Content = Get-Content $Psd1File

$CurrentPsd1VersionLine = $Psd1Content | Where-Object { $_ -Match '\s*ModuleVersion\s*=\s*' }
$NewPsd1VersionLine = ("    ModuleVersion = '{0}'" -f $NewPrereleaseVersion)

$Psd1Content -replace $CurrentPsd1VersionLine, $NewPsd1VersionLine | Out-File $Psd1File

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

Write-Host ("Publishing module in version '{0}' to '{1}'" -f $NewPrereleaseVersion, $LocalRepositoryName)
Publish-PSResource -Path $SourceFolder -ApiKey "abc" -Repository $LocalRepositoryName -Verbose

Write-Host ("Publishing module in version '{0}' to PSGallery" -f $NewPrereleaseVersion)
Publish-PSResource -Path $SourceFolder -ApiKey $NuGetApiKey -Repository "PSGallery" -Verbose



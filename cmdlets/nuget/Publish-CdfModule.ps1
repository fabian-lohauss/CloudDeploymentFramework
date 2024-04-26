param(
    [Parameter(Mandatory)]
    [string]$NuGetApiKey
)

$NugetFolder = $PSScriptRoot
$SourceFolder = Join-Path $NugetFolder -ChildPath ../src/CloudDeploymentFramework

$PublishedModule = Find-PSResource CloudDeploymentFramework
$CurrentVersion = $PublishedModule.Version

$NewVersion = [Version]::new($CurrentVersion.Major, $CurrentVersion.Minor, $CurrentVersion.Build + 1)

$Psd1File = Join-Path $SourceFolder -ChildPath CloudDeploymentFramework.psd1
$Psd1Content = Get-Content $Psd1File

$CurrentVersionLine = $Psd1Content | Where-Object { $_ -Match '\s*ModuleVersion\s*=\s*' }
$NewVersionLine = ("    ModuleVersion = '{0}'" -f $NewVersion)

$Psd1Content -replace $CurrentVersionLine, $NewVersionLine | Out-File $Psd1File

$LocalRepositoryName = "LocalRepository"
$LocalRepositoryPath = Join-Path $NugetFolder -ChildPath "Repository" -AdditionalChildPath $LocalRepositoryName -Resolve
New-Item -Path $LocalRepositoryPath -ItemType Directory -Force | Out-Null
if (Get-PSResourceRepository -Name $LocalRepositoryName -ErrorAction SilentlyContinue) {
    Set-PSResourceRepository -Name $LocalRepositoryName -Uri $LocalRepositoryPath -Trusted
}
else {
    Register-PSResourceRepository -Name $LocalRepositoryName -Uri $LocalRepositoryPath -Trusted
}
Publish-PSResource -Path $ModuleFolder -ApiKey "abc" -Repository $LocalRepositoryName -Verbose

Publish-PSResource -Path $ModuleFolder -ApiKey $NuGetApiKey -Repository "PSGallery" -Verbose



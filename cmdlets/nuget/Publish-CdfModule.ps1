param(
    [Parameter(Mandatory = $true)]
    [string]$NuGetApiKey,

    [Parameter(Mandatory = $true)]
    [string]$Version
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

if ($Version -match "-") {
    Write-Host "Prerelease version detected"
    $NewPrereleaseVersion = $Version
    Write-Host "New prerelease version: $NewPrereleaseVersion"
    if (Test-Path Env:GITHUB_STEP_SUMMARY) {
        ("New prerelease version is '{0}'" -f $NewPrereleaseVersion)  | Out-File -FilePath $Env:GITHUB_STEP_SUMMARY -Encoding utf8 -Append
    }
    $NewVersion = $NewPrereleaseVersion -split "-" | Select-Object -First 1
    Write-Host "New version for PSGallery: $NewVersion"

    $PrereleaseTag = $NewPrereleaseVersion -split "-" | Select-Object -Last 1
    Write-Host "Prerelease tag for PSGallery: $PrereleaseTag"
}
else {
    Write-Host "Release version detected"
    $NewVersion = $Version
    Write-Host "New version for PSGallery: $NewVersion"
    $PrereleaseTag = $null
    if (Test-Path Env:GITHUB_STEP_SUMMARY) {
        ("New release version is '{0}'" -f $NewVersion)  | Out-File -FilePath $Env:GITHUB_STEP_SUMMARY -Encoding utf8 -Append
    }
}



$Psd1File = Join-Path $SourceFolder -ChildPath CloudDeploymentFramework.psd1
$ManifestParameter = @{
    Path              = $Psd1File
    RootModule        = "CloudDeploymentFramework.psm1"
    GUID              = '1ad171ad-4dbe-4b99-ab7f-b20ec586da10'
    ModuleVersion     = $NewVersion
    Author            = "Fabian Lohauß"
    CompanyName       = ""
    Copyright         = 'Fabian Lohauß'
    Description       = 'Framework to deploy Azure resouces with PowerShell, Bicep, or Terraform'
    PowerShellVersion = '7.0'
    FunctionsToExport = '*'
    CmdletsToExport   = $PublicFunctions
    VariablesToExport = '*'
    AliasesToExport   = '*'
    FileList          = 'CloudDeploymentFramework.psm1'
}
if ($PrereleaseTag) {
    $ManifestParameter.Add("Prerelease", $PrereleaseTag)
}
New-ModuleManifest @ManifestParameter

Write-Host ("Publishing module in version '{0}' to '{1}'" -f $NewVersion, $LocalRepositoryName)
Publish-PSResource -Path $SourceFolder -ApiKey "abc" -Repository $LocalRepositoryName -Verbose

if ([string]::IsNullOrEmpty($NuGetApiKey)) {
    Write-Host ("Skipping publishing to PSGallery because no NuGetApiKey is provided")
}
else {
    Write-Host ("Publishing module in version '{0}' to PSGallery" -f $NewVersion)
    Publish-PSResource -Path $SourceFolder -ApiKey $NuGetApiKey -Repository "PSGallery" -Verbose
}




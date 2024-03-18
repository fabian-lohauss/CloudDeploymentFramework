function Get-DfGitConfig {
    $Config = git config --list
    $name = $Config | Select-String -Pattern "user.name=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $email = $Config | Select-String -Pattern "user.email=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    if ($config -match "https://(?:.*@)?(?:dev\.azure\.com|github\.com)/(?<org>[^/]+)/") { $OrganizationName = $Matches['org'] }
   
    [PSCustomObject]@{
        UserName         = $name
        UserEmail        = $email
        OrganizationName = $OrganizationName
    }
}
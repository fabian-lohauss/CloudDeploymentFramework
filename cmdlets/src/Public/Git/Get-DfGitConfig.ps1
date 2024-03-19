function Get-DfGitConfig {
    $Config = git config --list
    $name = $Config | Select-String -Pattern "user.name=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $email = $Config | Select-String -Pattern "user.email=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $OrganizationName = $Config | Select-String -Pattern "https://(.*@)?(dev\.azure\.com|github\.com)/(?<org>[^/]+)/" | ForEach-Object {  $_.Matches.Groups[3].Value }
   
    [PSCustomObject]@{
        UserName         = $name
        UserEmail        = $email
        OrganizationName = $OrganizationName
    }
}
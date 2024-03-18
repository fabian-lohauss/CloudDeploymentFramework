function Get-DfGitConfig {
    $Config = git config --list
    $name = $Config | Select-String -Pattern "user.name=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $email = $Config | Select-String -Pattern "user.email=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $organization = [regex]::Matches($Config, 'remote\.origin\.url=https?://(?:\w+@)?(?:www\.)?(github\.com|dev\.azure\.com)/(?<orgName>[^/]+)') | ForEach-Object {
        $_.Groups['orgName'].Value
    }
    
    [PSCustomObject]@{
        UserName     = $name
        UserEmail    = $email
        OrganizationName = $organization
    }
}
Write-Host "###############################################"
Write-Host "Installing PowerShell modules"
"Pester", "Az.Accounts", "Az.Resources", "Az.Keyvault" | ForEach-Object { 
    Install-PSResource $_ -Scope CurrentUser -TrustRepository 
}
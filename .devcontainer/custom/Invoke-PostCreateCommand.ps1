Write-Host "###############################################"
Write-Host "Installing PowerShell modules"
"Pester", "Az.Accounts", "Az.Resources", "Az.Keyvault" | ForEach-Object { 
    Install-PSResource $_ -Scope CurrentUser -TrustRepository -Verbose
}

Write-Host "###############################################"
Write-Host "Installing npm packages"
npm install -g @devcontainers/cli
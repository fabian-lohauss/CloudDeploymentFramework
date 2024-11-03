Write-Host "------------------------------------------------------------"
Write-Host "Installing PowerShell modules"
 
$Modules = "Pester", "Az.Accounts", "Az.Resources", "Az.Keyvault", "Az.Storage" 
Install-PSResource $Modules -Scope AllUsers -TrustRepository 

Write-Host "------------------------------------------------------------"
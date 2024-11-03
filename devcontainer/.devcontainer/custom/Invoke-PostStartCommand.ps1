Write-Host "############################################################"
Write-Host "Running post start command..."
Write-Host "############################################################"

Write-Host "Updating package cache and upgrading packages..."
sudo apt-get update
sudo apt-get upgrade -y

Write-Host "############################################################"
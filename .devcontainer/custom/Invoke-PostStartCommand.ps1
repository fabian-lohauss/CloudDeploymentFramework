sudo apt-get update
sudo apt-get upgrade -y

$userName = git config --global --get user.name 2>$null
$userEmail = git config --global --get user.email 2>$null

if (-not $userName -and $env:CdfUserName) {
	git config --global user.name $env:CdfUserName
	$userName = $env:CdfUserName
}

if (-not $userEmail -and $env:CdfUserEmail) {
	git config --global user.email $env:CdfUserEmail
	$userEmail = $env:CdfUserEmail
}

if (-not $userName -or -not $userEmail) {
	Write-Warning "Git author identity is not configured in the container."
	Write-Host "Set user.name and user.email in the host ~/.gitconfig, or define CdfUserName and CdfUserEmail before rebuilding the devcontainer."
}
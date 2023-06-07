Push-Location $PSScriptRoot

# Remove all images
docker images --quiet | Sort-Object -Unique | ForEach-Object { 
    docker image remove $_ --force 
}


npm install -g @devcontainers/cli
devcontainer build --image-name ghcr.io/fabian-lohauss/df-devcontainer:latest --platform "linux/amd64" --push false --workspace-folder . 

Set-PSRepository PSGallery -InstallationPolicy Trusted 
Install-Module Az.Accounts, Az.Keyvault
if ("c09a3fb8-03f0-4f0d-b59c-389d2fe9dedb" -ne (Get-AzContext).Tenant.Id) {

    Login-AzAccount -Tenant c09a3fb8-03f0-4f0d-b59c-389d2fe9dedb -UseDeviceAuthentication
}
Get-AzKeyVaultSecret -VaultName DeploymentFramework-kv -Name ContainerRegistryWriter -AsPlainText | docker login ghcr.io -u USERNAME --password-stdin
docker tag ghcr.io/fabian-lohauss/df-devcontainer ghcr.io/fabian-lohauss/df-devcontainer:v1.0
docker push ghcr.io/fabian-lohauss/df-devcontainer:latest


# devcontainer up --workspace-folder . 
# devcontainer exec --workspace-folder .  /bin/bash ./build.sh

Pop-Location


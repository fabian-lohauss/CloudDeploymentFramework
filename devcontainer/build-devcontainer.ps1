Push-Location $PSScriptRoot

devcontainer build --image-name ghcr.io/fabian-lohauss/df-devcontainer:latest --platform "linux/amd64" --push true --workspace-folder . 
# devcontainer up --workspace-folder . 
# devcontainer exec --workspace-folder .  /bin/bash ./build.sh

Pop-Location


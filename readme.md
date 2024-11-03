# Services 
* has one or more service components that are deployed to the service resource group
* might have scale out components that are deployed to stamp resource groups
* the service resource group is always deployed

## scale out service
load balancer deployed to the service resource group

load balancer backends are deployed to the stamp resource groups

# Stamps

* have a resource group as boundary
* contain at least one instance of all components of a service

# DeploymentFramework

[Cmdlets](cmdlets/readme.md)

# DevContainer
[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open%20in%20VS%20code&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/fabian-lohauss/CloudDeploymentFramework)

[Open in GitHub Codespaces](https://github.com/codespaces/new?repository=fabian-lohauss/CloudDeploymentFramework)

## Setup DevContainer prerequisites

[Install and configure DevContainer prerequisites](docs/readme.DevContainer.md)

# Setup local environment

```pwsh
Install-Module CloudDeploymentFramework
```

```pwsh
git config --global user.name $env:CdfUserName
git config --global user.email $env:CdfUserEmail

az extension add --upgrade -n bastion
az config set core.allow_broker=true
az account clear
az login

```

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

# Setup DevContainer prerequisites

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

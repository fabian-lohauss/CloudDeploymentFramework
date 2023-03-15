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
Function Connect-CdfRdp {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0, Mandatory = $true)]
        [string]$Name
    )

    Function Write-CdfLog {
        param (
            [Parameter(ValueFromPipelineByPropertyName, Position = 0, Mandatory = $true)]
            [string]$Message
        )
        Write-Host $Message
    }

    $TenantId = "ac12e5c3-077a-4f43-b2ef-834901540086"
    $SubscriptionId = "5577d40d-6f47-438f-bdb2-72d19a4c304e"
    $AccountId = "fabianl@MngEnv205548.onmicrosoft.com"

    Write-CdfLog ("Connecting to Azure with tenantId: {0}, subscriptionId: {1}, accountId: {2}" -f $TenantId, $SubscriptionId, $AccountId)

    Write-CdfLog ("Checking if Azure PowerShell module is installed")
    $AzModule = Get-Module -ListAvailable -Name Az
    if ($null -eq $AzModule) {
        Write-CdfLog ("Azure PowerShell module not found, installing")
        Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
        $AzModule = Get-Module -ListAvailable -Name Az
        if ($null -eq $AzModule) {
            throw "Failed to install Azure PowerShell module"
        }
    }

    Write-CdfLog ("Checking if Azure CLI is installed")
    $AzCli = Get-Command -Name az -ErrorAction SilentlyContinue
    if ($null -eq $AzCli) {
        Write-CdfLog ("Azure CLI not found, installing")
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
        Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        Remove-Item .\AzureCLI.msi
        $AzCli = Get-Command -Name az -ErrorAction SilentlyContinue
        if ($null -eq $AzCli) {
            throw "Failed to install Azure CLI"
        }
    }

    Write-CdfLog ("Checking if Azure PowerShell module is up to date")
    $AzModule = Get-Module -ListAvailable -Name Az
    if ($null -eq $AzModule) {
        throw "Azure PowerShell module not found"
    }

    Write-CdfLog ("Checking if Azure Az is logged in")
    $CmdletContext = Get-AzContext 
    Write-CdfLog ("Current Azure context: {0}" -f $CmdletContext.Name)
    if (($CmdletContext.Tenant.Id -ne $TenantId) -or ($CmdletContext.Subscription.Id -ne $SubscriptionId) -or ($CmdletContext.Account.Id -ne $AccountId)) {
        Write-CdfLog ("Expected Azure context: tenantId: {0}, subscriptionId: {1}, accountId: {2} but got tenantId: {3}, subscriptionId: {4}, accountId: {5}" -f $TenantId, $SubscriptionId, $AccountId, $CmdletContext.Tenant.Id, $CmdletContext.Subscription.Id, $CmdletContext.Account.Id)
        $CmdletContext = Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -AccountId $AccountId
        if (($CmdletContext.Tenant.Id -ne $TenantId) -or ($CmdletContext.Subscription.Id -ne $SubscriptionId) -or ($CmdletContext.Account.Id -ne $AccountId)) {
            throw "Failed to connect to Azure with Get-AzContext"
        }
    }

    Write-CdfLog ("Checking if Azure CLI is logged in")
    $AzContext = az account show | ConvertFrom-Json
    Write-CdfLog ("Current Azure context: {0}" -f $AzContext.name)
    if (($AzContext.tenantId -ne $TenantId) -or ($AzContext.user.name -ne $AccountId)) {
        Write-CdfLog ("Expected Azure context: tenantId: {0}, accountId: {1} but got tenantId: {2}, accountId: {3}" -f $TenantId, $AccountId, $AzContext.tenantId, $AzContext.user.name)
        az login --tenant $TenantId --use-device-code 
        $AzContext = az account show | ConvertFrom-Json
        if (($AzContext.tenantId -ne $TenantId) -or ($AzContext.user.name -ne $AccountId)) {
            throw "Failed to connect to Azure with az login"
        }
    }

    Write-CdfLog ("Checking if Azure Az is set to the correct subscription")
    if ($AzContext.id -ne $SubscriptionId) {
        Write-CdfLog ("Expected Azure subscriptionId: {0} but got subscriptionId: {1}" -f $SubscriptionId, $AzContext.id)
        az account set --subscription $SubscriptionId 
        $AzContext = az account show | ConvertFrom-Json

        if ($AzContext.id -ne $SubscriptionId) {
            throw "Failed to set subscription with az account set. Expected subscriptionId: $SubscriptionId, but got $($AzContext.id)"
        }
    }

    Write-CdfLog ("Checking if VM '{0}' exists" -f $Name)
    $VM = Get-AzVM -Name $Name
    if ($null -eq $VM) {
        throw ("VM '{0}' not found" -f $Name)
    }

    Write-CdfLog ("Checking if VM '{0}' has the required tags" -f $VM.Name)
    if ($null -eq $VM.Tags.DfBastionName) {
        throw ("Missing tag DfBastionName on VM '{0}'" -f $VM.Name)
    }
    if ($null -eq $VM.Tags.DfBastionResourceGroup) {
        throw ("Missing tag DfBastionResourceGroup on VM '{0}'" -f $VM.Name)
    }

    Write-CdfLog ("Checking if bastion '{0}' exists in resource group '{1}'" -f $VM.Tags.DfBastionName, $VM.Tags.DfBastionResourceGroup)
    $Bastion = Get-AzBastion -Name $VM.Tags.DfBastionName -ResourceGroupName $VM.Tags.DfBastionResourceGroup
    if ($null -eq $Bastion) {
        throw "Bastion not found"
    }

    Write-CdfLog ("Connecting to VM '{0}' via bastion '{1}' in resource group '{2}'" -f $VM.Name, $VM.Tags.DfBastionName, $VM.Tags.DfBastionResourceGroup)
    az network bastion rdp --name $VM.Tags.DfBastionName --resource-group $VM.Tags.DfBastionResourceGroup --target-resource-id $VM.Id
}
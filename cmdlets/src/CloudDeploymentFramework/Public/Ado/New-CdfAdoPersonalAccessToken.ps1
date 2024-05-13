enum AdoScope {
    PackagingRead = 0
    PackagingWrite
    ProjectRead
    CodeRead
}

function New-CdfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "Ado", Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = "AdoAndKeyvault", Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(ParameterSetName = "Ado", Mandatory)]
        [Parameter(ParameterSetName = "AdoAndKeyvault", Mandatory)]
        [Alias("SecretName")]
        [string]$PatDisplayName,

        [Parameter(ParameterSetName = "Ado", Mandatory)]
        [Parameter(ParameterSetName = "AdoAndKeyvault", Mandatory)]
        [AdoScope[]]$Scope,

        [Parameter(ParameterSetName = "AdoAndKeyvault", Mandatory)]
        [Alias("VaultName")	]
        [string]$KeyVaultName,

        [Parameter(ParameterSetName = "AdoAndKeyvault")]
        [switch]$AllowKeyVaultNetworkRuleUpdate,

        [switch]$PassThru,

        [switch]$Force

    )

    $Parameter = @{
        OrganizationName = $OrganizationName
        PatDisplayName   = $PatDisplayName
    }

    if (Test-CdfAdoPersonalAccessToken @Parameter) {
        if ($Force) {
            Remove-CdfAdoPersonalAccessToken @Parameter
        }
        else {
            throw ("Failed to create new personal access token '{0}': Personal access token already exists" -f $PatDisplayName)
        }
    }

    try {
        if ($PSCmdlet.ParameterSetName -eq "AdoAndKeyvault") {
            $Parameter.KeyVaultName = $KeyVaultName
            $Parameter.AllowKeyVaultNetworkRuleUpdate = $AllowKeyVaultNetworkRuleUpdate
        }
        
        $Result = Set-CdfAdoPersonalAccessToken @Parameter -Scope $Scope -PassThru
    }
    catch {
        throw [Exception]::new("Failed to create new personal access token '{0}'" -f $PatDisplayName, $_.Exception)
    }
    
    if ($PSCmdlet.MyInvocation.BoundParameters['PassThru']) {
        $PatTokenDetails = $Result.patToken
        return [PSCustomObject]$PatTokenDetails
    }
}

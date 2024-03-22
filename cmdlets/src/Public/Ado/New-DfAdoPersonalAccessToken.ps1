enum AdoScope {
    PackagingRead = 0
    PackagingWrite
    ProjectRead
    CodeRead
}

function New-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$PatDisplayName,

        [Parameter(Mandatory)]
        [AdoScope[]]$Scope,

        [string]$KeyVaultName,

        [switch]$PassThru,

        [switch]$Force

    )

    if (Test-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -PatDisplayName $PatDisplayName -KeyVaultName $KeyVaultName) {
        if ($Force) {
            Remove-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -PatDisplayName $PatDisplayName -KeyVaultName $KeyVaultName
        }
        else {
            throw ("Failed to create new personal access token '{0}': Personal access token already exists" -f $PatDisplayName)
        }
    }

    try {
        $Result = Set-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -PatDisplayName $PatDisplayName -Scope $Scope -KeyVaultName $KeyVaultName -PassThru
    }
    catch {
        throw [Exception]::new("Failed to create new personal access token '{0}'" -f $PatDisplayName, $_.Exception)
    }
    
    if ($PSCmdlet.MyInvocation.BoundParameters['PassThru']) {
        $PatTokenDetails = $Result.patToken
        return [PSCustomObject]$PatTokenDetails
    }
}

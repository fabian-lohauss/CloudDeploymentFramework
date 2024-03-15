enum AdoScope {
    PackagingRead = 0
    PackagingWrite
    ProjectRead
    CodeRead
}

function New-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [AdoScope[]]$Scope,

        [string]$KeyVaultName,

        [switch]$PassThru

    )

    if (Test-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -DisplayName $DisplayName) {
        throw ("Failed to create new personal access token '{0}': Personal access token already exists" -f $DisplayName)
    }

    try {
        $Result = Set-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -DisplayName $DisplayName -Scope $Scope -KeyVaultName $KeyVaultName -PassThru
    }
    catch {
        throw [Exception]::new("Failed to create new personal access token '{0}'" -f $DisplayName, $_.Exception)
    }
    
    if ($PSCmdlet.MyInvocation.BoundParameters['PassThru']) {
        $PatTokenDetails = $Result.patToken
        return [PSCustomObject]$PatTokenDetails
    }
}

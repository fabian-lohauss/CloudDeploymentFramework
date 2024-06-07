function Get-CdfAdoPersonalAccessToken {
    <#
    .SYNOPSIS
    Get personal access tokens for an Azure DevOps organization.

    .DESCRIPTION
    Get personal access tokens for an Azure DevOps organization.

    .PARAMETER OrganizationName
    The name of the Azure DevOps organization.

    .PARAMETER PatDisplayName
    The display name of the personal access token.

    .EXAMPLE
    Get-CdfAdoPersonalAccessToken -OrganizationName "MyOrganization"

    .EXAMPLE
    Get-CdfAdoPersonalAccessToken -OrganizationName "MyOrganization" -PatDisplayName "MyPat"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [string]$PatDisplayName
    )

    try {
        $Result = Invoke-CdfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method Get 
    }
    catch {
        throw [Exception]::new(("Failed to get personal access token: {0}" -f $_.Exception.Message), $_.Exception)
    }
    $PatTokens = $Result.PatTokens 
    if (-not [string]::IsNullOrEmpty($PatDisplayName)) {
        $PatTokens = $PatTokens | Where-Object { $_.displayName -eq $PatDisplayName }
    }

    $ResultObjects = @()
    foreach ($PatToken in $PatTokens) {
        $ResultObjects += [PSCustomObject]@{
            DisplayName      = $PatToken.displayName
            Token            = $PatToken.token
            ValidFrom        = $PatToken.validFrom
            ValidTo          = $PatToken.validTo
            Scope            = $PatToken.scope
            AuthorizationId  = $PatToken.authorizationId
            OrganizationName = $OrganizationName
        }
    }

    return $ResultObjects
}
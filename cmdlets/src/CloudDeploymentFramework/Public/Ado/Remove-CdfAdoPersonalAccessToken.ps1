function Remove-CdfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$PatDisplayName,

        [string]$KeyVaultName
    )

    try {
        $ExistingToken = Get-CdfAdoPersonalAccessToken -OrganizationName $OrganizationName -PatDisplayName $PatDisplayName

        if ($null -eq $ExistingToken) {
            return
        }

        if ($ExistingToken.Count -gt 1) {
            throw [Exception]::new("There are multiple personal access tokens with the same display name '{0}'" -f $PatDisplayName)
        }

        $Result = Invoke-CdfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method "Delete" -AuthorizationId $ExistingToken.authorizationId
    }
    catch {
        throw [Exception]::new(("Failed to remove personal access token '{0}': {1}" -f $PatDisplayName, $_.Exception.Message), $_.Exception)
    }
    
}
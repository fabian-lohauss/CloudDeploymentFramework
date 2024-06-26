function Test-CdfAdoPersonalAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName ='Ado', Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(ParameterSetName ='Ado', Mandatory = $true)]
        [string]$PatDisplayName
    )

    try {
        $Parameter = @{
            OrganizationName = $OrganizationName
            PatDisplayName   = $PatDisplayName
        }

        $PatTokens = Get-CdfAdoPersonalAccessToken @Parameter
        if ($PatTokens.Count -eq 0) {
            return $false
        }
        if ($PatTokens.Count -gt 1) {
            throw [Exception]::new("The personal access token name '$PatDisplayName' is not unique.")
        }
        $PatToken = $PatTokens[0]
        if (($null -ne $PatToken.validTo) -and ([DateTime]::Parse($PatToken.validTo) -lt [DateTime]::UtcNow)) {
            return $false
        }

        return $true
    }
    catch {
        throw [Exception]::new(("Failed to check personal access token: {0}" -f $_.Exception.Message), $_.Exception)
    }
}
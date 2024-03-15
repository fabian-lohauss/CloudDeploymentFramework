function Test-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    try {
        $PatTokens = Get-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -DisplayName $DisplayName
        if ($PatTokens.Count -eq 0) {
            return $false
        }
        if ($PatTokens.Count -gt 1) {
            throw [Exception]::new("The personal access token name '$DisplayName' is not unique.")
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
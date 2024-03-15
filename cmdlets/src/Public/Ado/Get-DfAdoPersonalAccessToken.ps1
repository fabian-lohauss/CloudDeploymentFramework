function Get-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [string]$DisplayName
    )

    try {
        $Result = Invoke-DfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method Get 
    }
    catch {
        throw [Exception]::new(("Failed to get personal access token: {0}" -f $_.Exception.Message), $_.Exception)
    }
    $PatTokens = $Result.PatTokens 
    if (-not [string]::IsNullOrEmpty($DisplayName)) {
        $PatTokens = $PatTokens | Where-Object { $_.displayName -eq $DisplayName }
    }

    return $PatTokens
}
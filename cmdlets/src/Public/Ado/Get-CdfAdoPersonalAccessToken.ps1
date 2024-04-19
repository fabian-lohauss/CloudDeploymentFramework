function Get-CdfAdoPersonalAccessToken {
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

    return $PatTokens
}
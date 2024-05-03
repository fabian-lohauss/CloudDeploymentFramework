function Get-CdfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [string]$PatDisplayName,

        [string]$KeyvaultName
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
        if (-not [string]::IsNullOrEmpty($KeyvaultName)) {
            try {
                $KeyVault = Get-AzKeyVault -VaultName $KeyvaultName 
                if (-not $KeyVault) {
                    throw [Exception]::new(("Key vault '{0}' not found." -f $KeyvaultName))
                }
                $KeyvaultSecretVersion = ($KeyVault | Get-AzKeyVaultSecret -Name $PatToken.DisplayName -ErrorAction Stop).Version
            }
            catch [System.ArgumentException] {
                $KeyvaultSecretVersion = [string]$null
            }
            catch {
                throw [Exception]::new(("Failed to look up keyvault secret of PAT '{0}' from keyvault '{1}': {2}" -f $PatToken.DisplayName, $KeyvaultName, $_.Exception.Message), $_.Exception)
            }
        }
        else {
            $KeyvaultSecretVersion = [string]$null
        }
        $ResultObjects += [PSCustomObject]@{
            DisplayName           = $PatToken.displayName
            Token                 = $PatToken.token
            ValidFrom             = $PatToken.validFrom
            ValidTo               = $PatToken.validTo
            Scope                 = $PatToken.scope
            OrganizationName      = $OrganizationName
            KeyvaultName          = $KeyvaultName
            KeyvaultSecretVersion = $KeyvaultSecretVersion 
        }
    }

    return $ResultObjects
}
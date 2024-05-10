Function Set-CdfSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [SecureString]$SecretValue,

        [Parameter(Mandatory)]
        [string]$VaultName,

        [datetime]$NotBefore,

        [datetime]$Expires,

        [switch]$AllowKeyVaultNetworkRuleUpdate,

        [switch]$PassThru
    )

    try {
        Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $SecretValue -ErrorAction Stop
    }
    catch {
        if (-not $AllowKeyVaultNetworkRuleUpdate) {
            throw $_
        }

        $Message = $_.Exception.Message
        $regex = [regex]::new('.*Operation.*Client address: (?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($regex.IsMatch($message)) {
            $ipAddress = $regex.Match($message).Groups['IP'].Value
            Add-AzKeyVaultNetworkRule -VaultName $VaultName -IpAddressRange $ipAddress
            Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $SecretValue -ErrorAction Stop
        }
        else {
            throw $_
        }
    }

}
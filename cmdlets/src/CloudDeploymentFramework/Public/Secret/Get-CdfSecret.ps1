Function Get-CdfSecret {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="default" , Mandatory)]
        [Parameter(ParameterSetName="AllowKeyVaultNetworkRuleUpdate" , Mandatory)]
        [string]$VaultName,

        [Parameter(ParameterSetName="default" , Mandatory)]
        [Parameter(ParameterSetName="AllowKeyVaultNetworkRuleUpdate" , Mandatory)]
        [string]$Name,

        [Parameter(ParameterSetName="default")]
        [Parameter(ParameterSetName="AllowKeyVaultNetworkRuleUpdate")]
        [switch]$AsPlainText,

        [Parameter(ParameterSetName="AllowKeyVaultNetworkRuleUpdate" , Mandatory)]
        [switch]$AllowKeyVaultNetworkRuleUpdate
    )

    try {
        $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -AsPlainText:$AsPlainText -ErrorAction Stop
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
            $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -AsPlainText:$AsPlainText -ErrorAction Stop
        }
        else {
            throw $_
        }
    }

    return $secret
}
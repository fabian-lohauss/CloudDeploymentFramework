Function Test-CdfSecret{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultName,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [switch]$AllowKeyVaultNetworkRuleUpdate
    )
    if (Get-CdfSecret -VaultName $VaultName -Name $Name -AllowKeyVaultNetworkRuleUpdate:$AllowKeyVaultNetworkRuleUpdate) {
        return $true
    }
    return $false
}
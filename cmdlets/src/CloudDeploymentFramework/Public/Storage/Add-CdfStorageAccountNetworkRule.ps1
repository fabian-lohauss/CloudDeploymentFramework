Function Add-CdfStorageAccountNetworkRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,

        [Parameter(Mandatory = $true)]
        [string]$IpAddress
    )

    $RuleSet = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    if ($RuleSet.IpRules.IPAddressOrRange -contains $IpAddress) {
        return
    }
    $RuleSet.IpRules += @{ Action = "Allow"; IPAddressOrRange = $IpAddress }
    Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -IPRule $RuleSet.IpRules
}
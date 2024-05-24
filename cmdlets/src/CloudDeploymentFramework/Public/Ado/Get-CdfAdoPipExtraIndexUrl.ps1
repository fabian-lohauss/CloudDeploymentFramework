Function Get-CdfAdoPipExtraIndexUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ProjectName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$SecretName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("KeyaultName")]
        [string]$VaultName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FeedName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AllowKeyVaultNetworkRuleUpdate
    )

    $PatToken = Get-CdfSecret -VaultName $VaultName -Name $SecretName -AllowKeyVaultNetworkRuleUpdate:$AllowKeyVaultNetworkRuleUpdate -AsPlainText
    
    $url = ("https://{0}:{1}@pkgs.dev.azure.com/{0}/{2}/_packaging/{3}/pypi/simple/" -f $OrganizationName, $PatToken, $ProjectName, $FeedName)
    return $url
}
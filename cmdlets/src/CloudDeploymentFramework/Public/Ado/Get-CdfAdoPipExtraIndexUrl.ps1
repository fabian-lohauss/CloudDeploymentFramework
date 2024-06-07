Function Get-CdfAdoPipExtraIndexUrl {
    <#
.SYNOPSIS
Get the extra index URL for a PIP feed in Azure DevOps.

.DESCRIPTION
Get the extra index URL for a PIP feed in Azure DevOps.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER ProjectName
The name of the Azure DevOps project.

.PARAMETER SecretName
The name of the secret containing the personal access token.

.PARAMETER VaultName
The name of the key vault containing the secret.

.PARAMETER FeedName
The name of the feed.

.PARAMETER AllowKeyVaultNetworkRuleUpdate
Allows to update the network rule of the key vault to allow the caller IP address to access the key vault.

.EXAMPLE
Get-CdfAdoPipExtraIndexUrl -OrganizationName "MyOrganization" -ProjectName "MyProject" -SecretName "MySecret" -VaultName "MyVault" -FeedName "MyFeed"
#>
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

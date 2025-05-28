
Function Connect-CdfContext {
    [CmdletBinding()]
    param ( )

    Connect-AzAccount -Subscription (Get-CdfProject).Environment.SubscriptionId
}
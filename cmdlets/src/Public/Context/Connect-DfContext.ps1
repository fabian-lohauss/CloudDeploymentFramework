
Function Connect-DfContext {
    [CmdletBinding()]
    param ( )

    Connect-AzAccount -Subscription (Get-DfProject).Environment.SubscriptionId
}
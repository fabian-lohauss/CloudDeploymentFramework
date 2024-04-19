
function Add-CdfEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "UseSubscription")]
        [Alias("Subscription")]
        [string]$Id,

        [Parameter(Mandatory, ParameterSetName = "UseCurrentAzureContext")]
        [switch]$CurrentAzureContext
    )
    
    $ConfigurationFile = Join-Path (Get-CdfProject).Path -ChildPath ".df/Configuration.json"
    $Config = Get-Content $ConfigurationFile | ConvertFrom-Json -AsHashtable
    switch ($PSCmdlet.ParameterSetName) {
        "UseSubscription" {
            $Subscription = $Id 
        }
        "UseCurrentAzureContext" {
            $Subscription = (Get-AzContext).Subscription.Id
        }
    }
    $Config.Environment = @{ $Name = @{ Subscription = $Subscription } }
    $Config | ConvertTo-Json | Out-File $ConfigurationFile
}
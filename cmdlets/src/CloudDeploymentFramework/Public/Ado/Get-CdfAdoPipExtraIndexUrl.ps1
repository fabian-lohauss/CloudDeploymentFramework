Function Get-CdfAdoPipExtraIndexUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ProjectName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PatDisplayName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$KeyvaultName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FeedName
    )

    $HexString = (Get-AzKeyVaultSecret -VaultName $KeyvaultName -Name $PatDisplayName).SecretValue | ConvertFrom-SecureString 
    
    $bytes = for ($i = 0; $i -lt $HexString.Length; $i += 2) {
        [Convert]::ToByte($HexString.Substring($i, 2), 16)
    }
    $PatToken = [System.Text.Encoding]::Unicode.GetString($bytes)
    
    $url = ("https://{0}:{1}@pkgs.dev.azure.com/{0}/{2}/_packaging/{3}/pypi/simple/" -f $OrganizationName, $PatToken, $ProjectName, $FeedName)
    return $url
}
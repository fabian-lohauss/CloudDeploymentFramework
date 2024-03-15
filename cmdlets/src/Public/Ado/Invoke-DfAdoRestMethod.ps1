function Invoke-DfAdoRestMethod {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$Api,

        [Parameter(Mandatory)]
        [string]$Method,

        [hashtable]$Body
    )

    $BearerToken = New-DfBearerToken
    $header = @{
        Authorization  = $BearerToken
        'Content-Type' = "application/json"
    }

    $BodyAsString = if ($Body) { $Body | ConvertTo-Json } else { $null }

    try {
        $Uri = ("https://vssps.dev.azure.com/{0}/_apis/{1}?api-version=7.1-preview.1" -f $OrganizationName, $Api)
        $Result = Invoke-RestMethod -Uri $Uri -Method $Method -Body $BodyAsString -Headers $header
        if ($Result -match "Azure DevOps Services \| Sign In") {
            throw "Sign in required. Run Connect-AzAccount to login."
        }
    }
    catch {
        throw [Exception]::new(("Failed to invoke ADO REST call to '{0}': {1}" -f $Uri, $_.Exception.Message), $_.Exception)
    }

    return $Result

}
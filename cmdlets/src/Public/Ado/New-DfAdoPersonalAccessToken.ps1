function New-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [string]$organizationName,
        [string]$displayName
    )

    $validTo = (Get-Date).AddDays(30).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    try {
        $BearerToken = New-DfBearerToken
    }
    catch {
        throw "Failed to create personal access token: $_"
    }

    $tokenBody = @{
        displayName = $displayName
        scope = "app_token.manage"
        validTo = $validTo
        allOrgs = $false
    }

    $header = @{
        Authorization = $BearerToken
        'Content-Type' = "application/json"
    }

    $JsonResult = Invoke-RestMethod -Uri "https://vssps.dev.azure.com/$organizationName/_apis/tokens/pats?api-version=7.1-preview.1" -Method Post -Body ($tokenBody | ConvertTo-Json) -Headers $header
    if ($JsonResult -match "Azure DevOps Services \| Sign In") {
        throw "Failed to create personal access token: Sign in required. Run Connect-AzAccount to login."
    }
    return [PSCustomObject]$JsonResult.patToken
}
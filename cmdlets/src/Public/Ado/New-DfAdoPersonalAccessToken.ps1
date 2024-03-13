enum AdoScope {
    None = 0
    PackagingRead
    PackagingWrite
    ProjectRead
    CodeRead
}

function New-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [AdoScope[]]$Scope,

        [string]$KeyVaultName
    )


    try {
        $BearerToken = New-DfBearerToken
    } catch {
        throw [Exception]::new("Failed to create personal access token", $_.Exception)
    }

    $scopeMap = @{
        PackagingRead = 'vso.packaging'
        PackagingWrite = 'vso.packaging_write'
        ProjectRead = 'vso.project'
        CodeRead = 'vso.code'
        CodeWrite = 'vso.code_write'
    }

    $selectedScopes = $Scope | Where-Object { $_ -ne 'None' } | ForEach-Object { $scopeMap[$_.ToString()] }
    if (-not $selectedScopes) {
        throw "No scopes selected. At least one scope must be specified."
    }
    $PatScope = $selectedScopes -join ' '

    $validTo = (Get-Date).AddDays(30).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $tokenBody = @{
        displayName = $displayName
        scope = $PatScope
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
    $PatTokenDetails = $JsonResult.patToken
    # $PatToken = $PatTokenDetails.token
    # $validFrom = [datetime]::Parse($PatTokenDetails.validFrom)
    # $validTo = [datetime]::Parse($PatTokenDetails.validTo)

    # $secretValue = ConvertTo-SecureString $PatToken -AsPlainText -Force
    # Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $displayName -SecretValue $secretValue -NotBefore $validFrom -Expires $validTo
    return [PSCustomObject]$PatTokenDetails
}

enum AdoScope {
    PackagingRead = 0
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

        [string]$KeyVaultName,

        [switch]$PassThru

    )

    if (Test-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -DisplayName $DisplayName) {
        throw ("Failed to create new personal access token '{0}': Personal access token already exists" -f $DisplayName)
    }

    $scopeMap = @{
        PackagingRead  = 'vso.packaging'
        PackagingWrite = 'vso.packaging_write'
        ProjectRead    = 'vso.project'
        CodeRead       = 'vso.code'
        CodeWrite      = 'vso.code_write'
    }

    $selectedScopes = $Scope | ForEach-Object { $scopeMap[$_.ToString()] }
    if (-not $selectedScopes) {
        throw "No scopes selected. At least one scope must be specified."
    }
    $PatScope = $selectedScopes -join ' '

    $validTo = (Get-Date).AddDays(30).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $tokenBody = @{
        displayName = $displayName
        scope       = $PatScope
        validTo     = $validTo
        allOrgs     = $false
    }

    try {
        $Result = Invoke-DfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method Post -Body $tokenBody 
    }
    catch {
        throw [Exception]::new("Failed to create new personal access token '{0}'" -f $DisplayName, $_.Exception)
    }

    $PatTokenDetails = $Result.patToken
    # $PatToken = $PatTokenDetails.token
    # $validFrom = [datetime]::Parse($PatTokenDetails.validFrom)
    # $validTo = [datetime]::Parse($PatTokenDetails.validTo)

    # $secretValue = ConvertTo-SecureString $PatToken -AsPlainText -Force
    # Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $displayName -SecretValue $secretValue -NotBefore $validFrom -Expires $validTo

    # check if PassThru is specified
    if ($PSCmdlet.MyInvocation.BoundParameters['PassThru']) {
        return [PSCustomObject]$PatTokenDetails
    }
}

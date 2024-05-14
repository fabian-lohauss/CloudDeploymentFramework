enum AdoScope {
    PackagingRead = 0
    PackagingWrite
    ProjectRead
    CodeRead
}

function Set-CdfAdoPersonalAccessToken {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Required to encrypt clear text PAT from API')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserName,

        [Parameter(Mandatory)]
        [string]$PatDisplayName,

        [Parameter(Mandatory)]
        [AdoScope[]]$Scope,

        [Alias("KeyvaultName")]
        [string]$VaultName,

        [switch]$AllowKeyVaultNetworkRuleUpdate,

        [switch]$PassThru

    )

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
        displayName = $PatDisplayName
        scope       = $PatScope
        validTo     = $validTo
        allOrgs     = $false
    }

    try {
        $ExistingToken = Get-CdfAdoPersonalAccessToken -OrganizationName $OrganizationName -PatDisplayName $PatDisplayName

        if ($ExistingToken.Count -gt 1) {
            throw [Exception]::new("There are multiple personal access tokens with the same display name '{0}'" -f $PatDisplayName)
        }

        $Method = "Post"
        if ($ExistingToken) {
            $Method = "Put"
            $tokenBody.authorizationId = $ExistingToken.authorizationId
        }

        $Result = Invoke-CdfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method $Method -Body $tokenBody 
        if ($Result.patTokenError -ne "none") {
            throw [Exception]::new($Result.patTokenError)
        }
    }
    catch {
        throw [Exception]::new(("Failed to create or update personal access token '{0}': {1}" -f $PatDisplayName, $_.Exception.Message), $_.Exception)
    }

    $PatTokenDetails = $Result.patToken
    $PatTokenDetails | Add-Member -MemberType NoteProperty -Name OrganizationName -Value $OrganizationName -Force
    $PatTokenDetails | Add-Member -MemberType NoteProperty -Name UserName -Value $UserName -Force   

    if (-not [string]::IsNullOrEmpty($VaultName)) {
        $PatToken = $PatTokenDetails.token
        $Parameters = @{
            Name                           = $PatDisplayName
            VaultName                      = $VaultName
            SecretValue                    = $PatTokenDetails
            NotBefore                      = [datetime]::Parse($PatTokenDetails.validFrom)
            Expires                        = [datetime]::Parse($PatTokenDetails.validTo)
            AllowKeyVaultNetworkRuleUpdate = $AllowKeyVaultNetworkRuleUpdate
        }

        Set-CdfSecret @Parameters -SecretValue (ConvertTo-SecureString $PatToken -AsPlainText)  | Out-Null
    }

    if ($PSCmdlet.MyInvocation.BoundParameters['PassThru']) {
        return [PSCustomObject]$PatTokenDetails
    }
}

BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}


Describe "Set-CdfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Get-CdfAdoPersonalAccessToken { throw "Get-CdfAdoPersonalAccessToken should be mocked" } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Set-CdfSecret { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory parameter OrganizationName " {
            Get-Command Set-CdfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory parameter PatDisplayName " {
            Get-Command Set-CdfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

        It "should have mandatory parameter scope" {
            Get-Command Set-CdfAdoPersonalAccessToken | Should -HaveParameter "Scope" -Mandatory 
        }

        It "should have optional parameter UserName" {
            Get-Command Set-CdfAdoPersonalAccessToken | Should -HaveParameter "UserName" -Type "string"
        }

        It "should have optional parameter VaultName" {
            Get-Command Set-CdfAdoPersonalAccessToken | Should -HaveParameter "VaultName" -Type "string"
        }
    }

    Context "exception from Invoke-CdfAdoRestMethod" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod { throw "Invoke-CdfAdoRestMethod: some exception." } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope CodeRead } | Should -Throw "Failed to create or update personal access token 'displayName': Invoke-CdfAdoRestMethod: some exception."
        }

        It "should have the Invoke-CdfAdoRestMethod as inner exception" {
            try {
                Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope PackagingRead
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-CdfAdoRestMethod: some exception."
            }
        }
    }

    Context "PatTokenError" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    patToken      = $null
                    patTokenError = "invalidAuthorizationId"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-CdfAdoPersonalAccessToken { return @{ DisplayName = "displayName" } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope PackagingRead } | Should -Throw "Failed to create or update personal access token 'displayName': invalidAuthorizationId"
        }
    }
  
    Context "new PAT without KeyVault" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    patToken      = [PSCustomObject]@{
                        displayName = $Body.displayName
                        validFrom   = "2023-12-31T18:38:34.69Z"
                        validTo     = $Body.validTo
                        scope       = $Body.scope
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the result with parameter -Passthru" {
            $Pat = Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -UserName "john doe" -Passthru
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "vso.packaging"
            $Pat.UserName | Should -Be "john doe"
            $Pat.OrganizationName | Should -Be "organizationName"
        }

        It "should not return anything without parameter -Passthru" {
            $Pat = Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            $Pat | Should -Be $null
        }

        It "should call Invoke-CdfAdoRestMethod" {
            Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            Assert-MockCalled Invoke-CdfAdoRestMethod -Exactly 1 -ParameterFilter { 
                $Api -eq "tokens/pats" -and $Method -eq "Post" -and $Body.displayName -eq "myNewPat" -and $Body.scope -eq "vso.packaging"
            } -ModuleName CloudDeploymentFramework
        }
    }

    Context "new PAT with keyvault" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    patToken      = [PSCustomObject]@{
                        displayName = $Body.displayName
                        validFrom   = "2023-12-31T18:38:34.69Z"
                        validTo     = $Body.validTo
                        scope       = $Body.scope
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfSecret { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should call Set-CdfSecret" {
            Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "myKeyVault"
            Assert-MockCalled Set-CdfSecret -Exactly 1 -ModuleName CloudDeploymentFramework -ParameterFilter { 
                $Name -eq "myNewPat" -and $VaultName -eq "myKeyVault" -and (ConvertFrom-SecureString $secretValue -AsPlainText) -eq "myNewPatToken" -and $NotBefore -eq "2023-12-31T18:38:34.69Z" -and $Expires -eq "2024-01-31T18:38:34.69Z" 
            }
        }
    }

    Context "PAT already exists" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return @(
                    [PSCustomObject]@{
                        authorizationid = "c64e9eda-e076-46d2-bb3a-1b39ffbb7298"
                        displayName     = "myExistingPat"
                        scope           = "vso.packaging"
                        validTo         = "2023-12-31T18:38:34.69Z"
                    }
                ) } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod { 
                param($Uri, $Method, $Body)
                $Result = @{
                    patToken      = @{
                        displayName = $Body.displayName
                        validFrom   = "2023-12-31T18:38:34.69Z"
                        validTo     = $Body.validTo
                        scope       = $Body.scope
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should update the token" {
            Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" 
            Assert-MockCalled Invoke-CdfAdoRestMethod -Exactly 1 -ParameterFilter { 
                $Api -eq "tokens/pats" -and $Method -eq "Put" -and $Body.displayName -eq "myNewPat" -and $Body.scope -eq "vso.packaging" -and $Body.authorizationId -eq "c64e9eda-e076-46d2-bb3a-1b39ffbb7298"
            } -ModuleName CloudDeploymentFramework
        }
    }

    Context "two PATs with the same name" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { 
                param($OrganizationName, $PatDisplayName)
                return [PSCustomObject]@(
                    [PSCustomObject]@{
                        id          = "id"
                        displayName = $PatDisplayName
                        scope       = "scope"
                        validTo     = "2022-01-01T00:00:00.000Z"
                    },
                    [PSCustomObject]@{
                        id          = "id"
                        displayName = $PatDisplayName
                        scope       = "scope"
                        validTo     = "2022-01-01T00:00:00.000Z"
                    }
                )
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" } | Should -Throw "Failed to create or update personal access token 'myNewPat': There are multiple personal access tokens with the same display name 'myNewPat'"
        }
    }

    Context "Parameter AllowKeyVaultNetworkRuleUpdate is set" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    patToken      = [PSCustomObject]@{
                        displayName = $Body.displayName
                        validFrom   = "2023-12-31T18:38:34.69Z"
                        validTo     = $Body.validTo
                        scope       = $Body.scope
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfSecret { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should pass AllowKeyVaultNetworkRuleUpdate to Set-CdfSecret" {
            Set-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -AllowKeyVaultNetworkRuleUpdate
            Assert-MockCalled Set-CdfSecret -Exactly 1 -ModuleName CloudDeploymentFramework -ParameterFilter { $AllowKeyVaultNetworkRuleUpdate -eq $true }
        }
    }
}

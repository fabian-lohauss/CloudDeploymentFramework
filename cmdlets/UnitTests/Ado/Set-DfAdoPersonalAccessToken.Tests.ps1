BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}


Describe "Set-DfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Get-DfAdoPersonalAccessToken { throw "Get-DfAdoPersonalAccessToken should be mocked" } -ModuleName DeploymentFramework -Verifiable
        Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
        Mock Set-AzKeyVaultSecret { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command Set-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater PatDisplayName " {
            Get-Command Set-DfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

        It "should have mandatory paramater scope" {
            Get-Command Set-DfAdoPersonalAccessToken | Should -HaveParameter "Scope" -Mandatory 
        }

        It "should have optional parameter UserName" {
            Get-Command Set-DfAdoPersonalAccessToken | Should -HaveParameter "UserName" -Type "string"
        }

        It "should have optional parameter KeyVaultName" {
            Get-Command Set-DfAdoPersonalAccessToken | Should -HaveParameter "KeyVaultName" -Type "string"
        }
    }

    Context "exception from Invoke-DfAdoRestMethod" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { throw "Invoke-DfAdoRestMethod: some exception." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope CodeRead } | Should -Throw "Failed to create or update personal access token 'displayName': Invoke-DfAdoRestMethod: some exception."
        }

        It "should have the Invoke-DfAdoRestMethod as inner exception" {
            try {
                Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope PackagingRead
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-DfAdoRestMethod: some exception."
            }
        }
    }
  
    Context "new PAT without KeyVault" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod {
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the result with parameter -Passthru" {
            $Pat = Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -UserName "john doe" -Passthru
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "vso.packaging"
            $Pat.UserName | Should -Be "john doe"
            $Pat.OrganizationName | Should -Be "organizationName"
        }

        It "should not return anything without parameter -Passthru" {
            $Pat = Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            $Pat | Should -Be $null
        }

        It "should call Invoke-DfAdoRestMethod" {
            Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            Assert-MockCalled Invoke-DfAdoRestMethod -Exactly 1 -ParameterFilter { 
                $Api -eq "tokens/pats" -and $Method -eq "Post" -and $Body.displayName -eq "myNewPat" -and $Body.scope -eq "vso.packaging"
            } -ModuleName DeploymentFramework
        }
    }

    Context "new PAT with keyvault" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod {
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
            } -ModuleName DeploymentFramework -Verifiable
            Mock Set-AzKeyVaultSecret { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should call Set-AzKeyVaultSecret" {
            Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "myKeyVault"
            Assert-MockCalled Set-AzKeyVaultSecret -Exactly 1 -ModuleName DeploymentFramework -ParameterFilter { 
                $Name -eq "myNewPat" -and $VaultName -eq "myKeyVault" -and (ConvertFrom-SecureString $secretValue -AsPlainText) -eq "myNewPatToken" -and $NotBefore -eq "2023-12-31T18:38:34.69Z" -and $Expires -eq "2024-01-31T18:38:34.69Z" 
            }
        }
    }

    Context "PAT already exists" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return @(
                    [PSCustomObject]@{
                        authorizationid = "c64e9eda-e076-46d2-bb3a-1b39ffbb7298"
                        displayName     = "myExistingPat"
                        scope           = "vso.packaging"
                        validTo         = "2023-12-31T18:38:34.69Z"
                    }
                ) } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { 
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should update the token" {
            Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" 
            Assert-MockCalled Invoke-DfAdoRestMethod -Exactly 1 -ParameterFilter { 
                $Api -eq "tokens/pats" -and $Method -eq "Put" -and $Body.displayName -eq "myNewPat" -and $Body.scope -eq "vso.packaging" -and $Body.authorizationId -eq "c64e9eda-e076-46d2-bb3a-1b39ffbb7298"
            } -ModuleName DeploymentFramework
        }
    }

    Context "two PATs with the same name" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { 
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Set-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" } | Should -Throw "Failed to create or update personal access token 'myNewPat': There are multiple personal access tokens with the same display name 'myNewPat'"
        }
    }
}

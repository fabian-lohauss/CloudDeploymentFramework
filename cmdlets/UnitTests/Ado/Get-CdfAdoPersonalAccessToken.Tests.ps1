BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Get-AzKeyVaultSecret { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName" {
            Get-Command Get-CdfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have optional paramater PatDisplayName" {
            Get-Command Get-CdfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" 
        }
    }

    Context "result schema" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        @{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        @{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return an array of PATs" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName"
            $PatTokens | Should -BeOfType [PSCustomObject]
            $PatTokens[0] | Should -BeOfType [PSCustomObject]
            $PatTokens[0].DisplayName | Should -BeOfType [System.String]
            $PatTokens[0].ValidFrom | Should -BeOfType [System.String]
            $PatTokens[0].ValidTo | Should -BeOfType [System.String]
            $PatTokens[0].Scope | Should -BeOfType [System.String]
            $PatTokens[0].Token | Should -BeOfType [System.String]
            $PatTokens[0].OrganizationName | Should -BeOfType [System.String]
            $PatTokens[0].KeyvaultName | Should -BeOfType [System.String]
            $PatTokens[0].KeyvaultSecretVersion | Should -BeOfType [System.String]
        }
    }

    Context "without PAT filter" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        @{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        @{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return all PATs" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName"
            $PatTokens.Count | Should -Be 2
            $PatTokens[0].displayName | Should -Be "pat1"
            $PatTokens[1].displayName | Should -Be "pat2"
        }
    }

    Context "with PAT filter" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    PatTokens = [PSCustomObject]@(
                        [PSCustomObject]@{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        [PSCustomObject]@{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return only the PAT with the specified name" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "pat2"
            $PatTokens.Count | Should -Be 1
            $PatTokens[0].displayName | Should -Be "pat2"
        }
    }

    Context "exception from Invoke-CdfAdoRestMethod" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod { throw "Invoke-CdfAdoRestMethod: some exception." } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Get-CdfAdoPersonalAccessToken -organizationName "organizationName" } | Should -Throw "Failed to get personal access token: Invoke-CdfAdoRestMethod: some exception."
        }

        It "should have the Invoke-CdfAdoRestMethod as inner exception" {
            try {
                Get-CdfAdoPersonalAccessToken -organizationName "organizationName"
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-CdfAdoRestMethod: some exception."
            }
        }
    }

    Context "no PATs returned" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @()
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return an empty array" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName"
            $PatTokens.Count | Should -Be 0
        }
    }

    Context "no PAT matches filter" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        [PSCustomObject]@{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        [PSCustomObject]@{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return [PSCustomObject]$Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return an empty array" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "pat3"
            $PatTokens.Count | Should -Be 0
        }
    }

    Context "with KeyvaultName parameter" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        @{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        @{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-AzKeyVaultSecret {
                param($VaultName, $Name)
                return [PSCustomObject]@{
                    Version = "$Name-version"
                }
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-AzKeyVault { return [PSCustomObject]@{ ResourceId = "theKeyvaultResourceId" } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return PATs with KeyvaultSecretVersion" {
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -KeyvaultName "keyvaultName"
            $PatTokens[0].KeyvaultSecretVersion | Should -Be "pat1-version"
            $PatTokens[1].KeyvaultSecretVersion | Should -Be "pat2-version"
        }

        It "should return PATs with KeyvaultSecretVersion as null if secret not found" {
            Mock Get-AzKeyVaultSecret { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -KeyvaultName "keyvaultName"
            $PatTokens[0].KeyvaultSecretVersion | Should -Be $null
            $PatTokens[1].KeyvaultSecretVersion | Should -Be $null
        }

        It "should throw if Get-AzKeyVaultSecret throws" {
            Mock Get-AzKeyVaultSecret { throw "Get-AzKeyVaultSecret: some exception." } -ModuleName CloudDeploymentFramework -Verifiable
            { Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -KeyvaultName "keyvaultName" } | Should -Throw "Failed to look up keyvault secret of PAT 'pat1' from keyvault 'keyvaultName': Get-AzKeyVaultSecret: some exception."
        }
    }

    Context "with exception from Get-AzKeyVaultSecret" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        @{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        @{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-AzKeyVault { return [PSCustomObject]@{ ResourceId = "theKeyvaultResourceId" } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should ignore [System.ArgumentException]: Invalid ObjectIdentifier" {
            Mock Get-AzKeyVaultSecret { throw [System.ArgumentException]"Invalid ObjectIdentifier" } -ModuleName CloudDeploymentFramework -Verifiable
            $PatTokens = Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -KeyvaultName "keyvaultName"
            $PatTokens.Count | Should -Be 2
        }
    }

    Context "keyvault does not exists" {
        BeforeAll {
            Mock Invoke-CdfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @(
                        @{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        @{
                            displayName = "pat2"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "PackagingRead"
                            token       = "myPatToken2"
                        }
                    )
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-AzKeyVault { return $null } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Get-CdfAdoPersonalAccessToken -OrganizationName "organizationName" -KeyvaultName "keyvaultName" } | Should -Throw "Failed to look up keyvault secret of PAT 'pat1' from keyvault 'keyvaultName': Key vault 'keyvaultName' not found."
            Assert-MockCalled Get-AzKeyVault -Exactly 1 -Scope It -ModuleName CloudDeploymentFramework
        }
    }
}
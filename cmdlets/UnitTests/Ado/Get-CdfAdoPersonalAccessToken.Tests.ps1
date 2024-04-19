BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName" {
            Get-Command Get-CdfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have optional paramater PatDisplayName" {
            Get-Command Get-CdfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" 
        }
    }

    Context "without filter" {
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

    Context "with filter" {
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
}
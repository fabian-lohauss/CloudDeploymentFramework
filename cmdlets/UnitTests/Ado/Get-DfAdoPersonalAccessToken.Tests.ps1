BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName" {
            Get-Command Get-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have optional paramater DisplayName" {
            Get-Command Get-DfAdoPersonalAccessToken | Should -HaveParameter "DisplayName" 
        }
    }

    Context "without filter" {
        BeforeAll {
            Mock Invoke-DfAdoRestMethod {
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return all PATs" {
            $PatTokens = Get-DfAdoPersonalAccessToken -OrganizationName "organizationName"
            $PatTokens.Count | Should -Be 2
            $PatTokens[0].displayName | Should -Be "pat1"
            $PatTokens[1].displayName | Should -Be "pat2"
        }
    }

    Context "with filter" {
        BeforeAll {
            Mock Invoke-DfAdoRestMethod {
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return only the PAT with the specified name" {
            $PatTokens = Get-DfAdoPersonalAccessToken -OrganizationName "organizationName" -DisplayName "pat2"
            $PatTokens.Count | Should -Be 1
            $PatTokens[0].displayName | Should -Be "pat2"
        }
    }

    Context "exception from Invoke-DfAdoRestMethod" {
        BeforeAll {
            Mock Invoke-DfAdoRestMethod { throw "Invoke-DfAdoRestMethod: some exception." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Get-DfAdoPersonalAccessToken -organizationName "organizationName" } | Should -Throw "Failed to get personal access token: Invoke-DfAdoRestMethod: some exception."
        }

        It "should have the Invoke-DfAdoRestMethod as inner exception" {
            try {
                Get-DfAdoPersonalAccessToken -organizationName "organizationName"
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-DfAdoRestMethod: some exception."
            }
        }
    }

    Context "no PATs returned" {
        BeforeAll {
            Mock Invoke-DfAdoRestMethod {
                param($Uri, $Method, $Body)
                $Result = @{
                    PatTokens = @()
                }
                return $Result
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return an empty array" {
            $PatTokens = Get-DfAdoPersonalAccessToken -OrganizationName "organizationName"
            $PatTokens.Count | Should -Be 0
        }
    }

    Context "no PAT matches filter" {
        BeforeAll {
            Mock Invoke-DfAdoRestMethod {
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
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return an empty array" {
            $PatTokens = Get-DfAdoPersonalAccessToken -OrganizationName "organizationName" -DisplayName "pat3"
            $PatTokens.Count | Should -Be 0
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}


Describe "Test-DfAdoPersonalAccessToken" {
    Context "parameters" {
        It "should have mandatory paramater OrganizationName" {
            Get-Command Test-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have optional paramater PatDisplayName" {
            Get-Command Test-DfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

    }

    Context "PAT does not exist" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return @() } -ModuleName DeploymentFramework -Verifiable
        }
 
        It "should return false" {
            Test-DfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "Test" | Should -Be $false
        }
    }

    Context "valid PAT exists" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken {
                param($OrganizationName, $PatDisplayName)
                return [PSCustomObject]@(
                    [PSCustomObject]@{
                        id          = "id"
                        displayName = $PatDisplayName
                        scope       = "scope"
                        validTo     = (Get-Date).AddDays(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    }
                )
            } -ModuleName DeploymentFramework -Verifiable
        }
        It "should return true" {
            Test-DfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "pat" | Should -Be $true
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
        It "should throw an exception" {
            { Test-DfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "pat" } | Should -Throw "Failed to check personal access token: The personal access token name 'pat' is not unique."
        }
    }

    Context "PAT exists but is expired" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken {
                param($OrganizationName, $PatDisplayName)
                return [PSCustomObject]@(
                    [PSCustomObject]@{
                        id          = "id"
                        displayName = $PatDisplayName
                        scope       = "scope"
                        validTo     = "2020-01-01T00:00:00.000Z"
                    }
                )
            } -ModuleName DeploymentFramework -Verifiable
        }
        It "should return false" {
            Test-DfAdoPersonalAccessToken -OrganizationName "organizationName" -PatDisplayName "pat" | Should -Be $false
        }
    }
}
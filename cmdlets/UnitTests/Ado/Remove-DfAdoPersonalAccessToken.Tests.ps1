BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}


Describe "Remove-DfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Get-DfAdoPersonalAccessToken { throw "Get-DfAdoPersonalAccessToken should be mocked" } -ModuleName DeploymentFramework -Verifiable
        Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command Remove-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater DisplayName " {
            Get-Command Remove-DfAdoPersonalAccessToken | Should -HaveParameter "DisplayName" -Mandatory
        }

        It "should have optional paramater KeyVaultName" {
            Get-Command Remove-DfAdoPersonalAccessToken | Should -HaveParameter "KeyVaultName" -Type "string"
        }
    }

    Context "exception from Invoke-DfAdoRestMethod" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken {                 
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    PatTokens = [PSCustomObject]@(
                        [PSCustomObject]@{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        }
                    )
                }
                return $Result } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { throw "Invoke-DfAdoRestMethod: some exception." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Throw "Failed to remove personal access token 'displayName': Invoke-DfAdoRestMethod: some exception."
        }

        It "should have the Invoke-DfAdoRestMethod as inner exception" {
            try {
                Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName"
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-DfAdoRestMethod: some exception."
            }
        }
    }
  
    Context "PAT removed successfully" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { 
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    PatTokens = [PSCustomObject]@(
                        [PSCustomObject]@{
                            displayName = "pat1"
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        }
                    )
                }
                return $Result
            } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should not throw" {
            { Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Not -Throw
        }

        It "should call Invoke-DfAdoRestMethod" {
            Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName"
            Assert-MockCalled Invoke-DfAdoRestMethod -Exactly 1 -Scope It -ModuleName DeploymentFramework
        }
    }

    Context "PAT removed successfully with KeyVaultName" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should delete the PAT from the KeyVault" {
            Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" -KeyVaultName "keyVaultName"
            Assert-MockCalled Remove-DfKeyVaultSecret -Exactly 1 -Scope It -ModuleName DeploymentFramework
        }
    }

    Context "PAT not found" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod {  } -ModuleName DeploymentFramework -Verifiable
        }

        It "return null" {
            Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" | Should -Be $null
        }
    }

    Context "multiple PATs with the same name" {
        BeforeAll {
            Mock Get-DfAdoPersonalAccessToken { 
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    PatTokens = [PSCustomObject]@(
                        [PSCustomObject]@{
                            displayName = $Body.DisplayName
                            validFrom   = "2023-12-31T18:38:34.69Z"
                            validTo     = "2024-01-01T18:38:34.69Z"
                            scope       = "CodeRead"
                            token       = "myPatToken1"
                        },
                        [PSCustomObject]@{
                            displayName = $Body.DisplayName
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

        It "should throw" {
            { Remove-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Throw "Failed to remove personal access token 'displayName': There are multiple personal access tokens with the same display name 'displayName'"
        }
    }
}
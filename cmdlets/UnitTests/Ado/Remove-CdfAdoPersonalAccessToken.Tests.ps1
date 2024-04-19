BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}


Describe "Remove-CdfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Get-CdfAdoPersonalAccessToken { throw "Get-CdfAdoPersonalAccessToken should be mocked" } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command Remove-CdfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater PatDisplayName " {
            Get-Command Remove-CdfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

        It "should have optional paramater KeyVaultName" {
            Get-Command Remove-CdfAdoPersonalAccessToken | Should -HaveParameter "KeyVaultName" -Type "string"
        }
    }

    Context "exception from Invoke-CdfAdoRestMethod" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken {                 
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
                return $Result } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod { throw "Invoke-CdfAdoRestMethod: some exception." } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" } | Should -Throw "Failed to remove personal access token 'displayName': Invoke-CdfAdoRestMethod: some exception."
        }

        It "should have the Invoke-CdfAdoRestMethod as inner exception" {
            try {
                Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName"
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-CdfAdoRestMethod: some exception."
            }
        }
    }
  
    Context "PAT removed successfully" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { 
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@{
                    displayName     = "pat1"
                    validFrom       = "2023-12-31T18:38:34.69Z"
                    validTo         = "2024-01-01T18:38:34.69Z"
                    scope           = "CodeRead"
                    token           = "myPatToken1"
                    authorizationId = "authorizationId"
                }
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should not throw" {
            { Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" } | Should -Not -Throw
        }

        It "should call Invoke-CdfAdoRestMethod" {
            Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName"
            Assert-MockCalled Invoke-CdfAdoRestMethod -Exactly 1 -Scope It -ParameterFilter { $AuthorizationId -eq "authorizationId" }  -ModuleName CloudDeploymentFramework
        }
    }

    Context "PAT removed successfully with KeyVaultName" -Skip {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should delete the PAT from the KeyVault" {
            Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -KeyVaultName "keyVaultName"
            Assert-MockCalled Remove-CdfKeyVaultSecret -Exactly 1 -Scope It -ModuleName CloudDeploymentFramework
        }
    }

    Context "PAT not found" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-CdfAdoRestMethod {  } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "return null" {
            Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" | Should -Be $null
        }
    }

    Context "multiple PATs with the same name" {
        BeforeAll {
            Mock Get-CdfAdoPersonalAccessToken { 
                param($Uri, $Method, $Body)
                $Result = [PSCustomObject]@(
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
                return $Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Remove-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" } | Should -Throw "Failed to remove personal access token 'displayName': There are multiple personal access tokens with the same display name 'displayName'"
        }
    }
}
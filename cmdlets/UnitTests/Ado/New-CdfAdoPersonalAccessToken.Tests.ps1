BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}


Describe "New-CdfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Test-CdfAdoPersonalAccessToken { throw "Test-CdfAdoPersonalAccessToken should be mocked" } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Set-CdfAdoPersonalAccessToken { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater DisplayName " {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

        It "should have mandatory paramater scope" {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "Scope" -Mandatory
        }

        It "should have optional paramater KeyVaultName" {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "KeyVaultName" -Type String
        }

        It "should have optional paramater Passthru" {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "Passthru" -Type Switch
        }

        It "should have optional paramater Force" {
            Get-Command New-CdfAdoPersonalAccessToken | Should -HaveParameter "Force" -Type Switch
        }
    }

    Context "exception from Invoke-CdfAdoRestMethod" {
        BeforeAll {
            Mock Test-CdfAdoPersonalAccessToken { return $false } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfAdoPersonalAccessToken { throw "Set-CdfAdoPersonalAccessToken: some exception." } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope CodeRead } | Should -Throw "Failed to create new personal access token 'displayName'"
        }

        It "should have the Set-CdfAdoPersonalAccessToken as inner exception" {
            try {
                New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope PackagingRead
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Set-CdfAdoPersonalAccessToken: some exception."
            }
        }
    }
  
    Context "new PAT created successfully" {
        BeforeAll {
            Mock Test-CdfAdoPersonalAccessToken { return $false } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfAdoPersonalAccessToken {
                param($PatDisplayName, $Scope)
                $Result = [PSCustomObject]@{
                    patToken      = [PSCustomObject]@{
                        displayName = $PatDisplayName
                        validFrom   = [datetime]"2023-12-31T18:38:34.69Z"
                        validTo     = [datetime]"2024-01-31T18:38:34.69Z"
                        scope       = "vso.packaging"
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return [PSCustomObject]$Result
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the result with parameter -Passthru" {
            $Pat = New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -Passthru
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "vso.packaging"
        }

        It "should not return anything without parameter -Passthru" {
            $Pat = New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            $Pat | Should -Be $null
        }
    }

    Context "PAT already exists" {
        BeforeAll {
            Mock Test-CdfAdoPersonalAccessToken { return $true } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfAdoPersonalAccessToken { throw "should not be called" } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" } | Should -Throw "Failed to create new personal access token 'myNewPat': Personal access token already exists"
        }
    }

    Context "-force creates new PAT" {
        BeforeAll {
            Mock Test-CdfAdoPersonalAccessToken { return $true } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Remove-CdfAdoPersonalAccessToken { } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Set-CdfAdoPersonalAccessToken { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should not throw" {
            { New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force } | Should -Not -Throw
        }

        It "should call Remove-CdfAdoPersonalAccessToken" {
            New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force
            Assert-MockCalled Remove-CdfAdoPersonalAccessToken -Scope It -ParameterFilter { $PatDisplayName -eq "myNewPat" -and $organizationName -eq "organizationName" -and $KeyVaultName -eq "TheKeyvault"  } -ModuleName CloudDeploymentFramework
        }

        It "should call Set-CdfAdoPersonalAccessToken" {
            New-CdfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force
            Assert-MockCalled Set-CdfAdoPersonalAccessToken -Scope It -ParameterFilter { $PatDisplayName -eq "myNewPat" -and $organizationName -eq "organizationName" -and "PackagingRead" -eq $scope -and $KeyVaultName -eq "TheKeyvault" } -ModuleName CloudDeploymentFramework
        }
    }
}

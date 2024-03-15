BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}


Describe "New-DfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Test-DfAdoPersonalAccessToken { throw "Test-DfAdoPersonalAccessToken should be mocked" } -ModuleName DeploymentFramework -Verifiable
        Mock Invoke-DfAdoRestMethod { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater DisplayName " {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "DisplayName" -Mandatory
        }

        It "should have mandatory paramater scope" {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "Scope" -Mandatory
        }
    }

    Context "exception from Invoke-DfAdoRestMethod" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $false } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { throw "Invoke-DfAdoRestMethod: some exception." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" -Scope CodeRead  } | Should -Throw "Failed to create new personal access token 'displayName'"
        }

        It "should have the Invoke-DfAdoRestMethod as inner exception" {
            try {
                New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" -Scope PackagingRead
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Invoke-DfAdoRestMethod: some exception."
            }
        }
    }
  
    Context "new PAT created successfully" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $false } -ModuleName DeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName DeploymentFramework -Verifiable
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

        It "should return the result with parameter -Passthru" {
            $Pat = New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "myNewPat" -Scope "PackagingRead" -Passthru
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "vso.packaging"
        }

        It "should not return anything without parameter -Passthru" {
            $Pat = New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "myNewPat" -Scope "PackagingRead"
            $Pat | Should -Be $null
        }
    }

    Context "PAT already exists" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $true } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-DfAdoRestMethod { throw "should not be called" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "myNewPat" -Scope "PackagingRead" } | Should -Throw "Failed to create new personal access token 'myNewPat': Personal access token already exists"
        }
    }
}

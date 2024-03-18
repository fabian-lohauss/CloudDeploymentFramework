BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Invoke-DfAdoRestMethod" {
    BeforeAll {
        Mock Get-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
    }

    Context "parameters" {
        It "should have mandatory organization name" {
            Get-Command Invoke-DfAdoRestMethod | Should -HaveParameter OrganizationName -Mandatory
        }
        It "should have mandatory api" {
            Get-Command Invoke-DfAdoRestMethod | Should -HaveParameter Api -Mandatory
        }
        It "should have mandatory method" {
            Get-Command Invoke-DfAdoRestMethod | Should -HaveParameter Method -Mandatory
        }
        It "should have optional body" {
            Get-Command Invoke-DfAdoRestMethod | Should -HaveParameter Body 
        }

        It "should have optional AuthorizationId parameter" {
            Get-Command Invoke-DfAdoRestMethod | Should -HaveParameter AuthorizationId -Type "string"
        }

    }
    
    Context "sign in popup" {
        BeforeAll {
            Mock Get-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                return @"
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                <html lang="en-US">
                <head><title>
                            Azure DevOps Services | Sign In
                </title></head>
"@
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-DfAdoRestMethod -OrganizationName a -Api "b" -Method Put } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/a/_apis/b?api-version=7.1-preview.1': Sign in required. Run Connect-AzAccount to login."
        }
    }

    Context "expired Azure token" {
        BeforeAll {
            Mock Get-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                throw "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-DfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/organizationName/_apis/b?api-version=7.1-preview.1': TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
        }

        It "should have the Invoke-RestMethod exception as inner exception" {
            try {
                Invoke-DfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
            }
        }
    }

    Context "other exception" {
        BeforeAll {
            Mock Get-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                throw "an exception"
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-DfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/organizationName/_apis/b?api-version=7.1-preview.1': an exception"
        }

        It "should have the Invoke-RestMethod exception as inner exception" {
            try {
                Invoke-DfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "an exception"
            }
        }
    }


    Context "AuthorizationId" {
        BeforeAll {
            Mock Get-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should use the AuthorizationId" {
            Invoke-DfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get -AuthorizationId "myToken"
            Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope It -ParameterFilter { $Uri -match "\?authorizationId=myToken&" } -ModuleName DeploymentFramework
        }
    }
}
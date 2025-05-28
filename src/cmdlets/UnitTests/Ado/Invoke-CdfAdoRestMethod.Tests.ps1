BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Invoke-CdfAdoRestMethod" {
    BeforeAll {
        Mock Get-CdfBearerToken { return "" } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "parameters" {
        It "should have mandatory organization name" {
            Get-Command Invoke-CdfAdoRestMethod | Should -HaveParameter OrganizationName -Mandatory
        }
        It "should have mandatory api" {
            Get-Command Invoke-CdfAdoRestMethod | Should -HaveParameter Api -Mandatory
        }
        It "should have mandatory method" {
            Get-Command Invoke-CdfAdoRestMethod | Should -HaveParameter Method -Mandatory
        }
        It "should have optional body" {
            Get-Command Invoke-CdfAdoRestMethod | Should -HaveParameter Body 
        }

        It "should have optional AuthorizationId parameter" {
            Get-Command Invoke-CdfAdoRestMethod | Should -HaveParameter AuthorizationId -Type "string"
        }

    }
    
    Context "sign in popup" {
        BeforeAll {
            Mock Get-CdfBearerToken { return "" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                return @"
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                <html lang="en-US">
                <head><title>
                            Azure DevOps Services | Sign In
                </title></head>
"@
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-CdfAdoRestMethod -OrganizationName a -Api "b" -Method Put } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/a/_apis/b?api-version=7.1-preview.1': Sign in required. Run Connect-AzAccount to login."
        }
    }

    Context "expired Azure token" {
        BeforeAll {
            Mock Get-CdfBearerToken { return "" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                throw "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-CdfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/organizationName/_apis/b?api-version=7.1-preview.1': TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
        }

        It "should have the Invoke-RestMethod exception as inner exception" {
            try {
                Invoke-CdfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
            }
        }
    }

    Context "other exception" {
        BeforeAll {
            Mock Get-CdfBearerToken { return "" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                throw "an exception"
            } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Invoke-CdfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get } | Should -Throw "Failed to invoke ADO REST call to 'https://vssps.dev.azure.com/organizationName/_apis/b?api-version=7.1-preview.1': an exception"
        }

        It "should have the Invoke-RestMethod exception as inner exception" {
            try {
                Invoke-CdfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "an exception"
            }
        }
    }


    Context "AuthorizationId" {
        BeforeAll {
            Mock Get-CdfBearerToken { return "" } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Invoke-RestMethod { } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should use the AuthorizationId" {
            Invoke-CdfAdoRestMethod -organizationName "organizationName" -Api "b" -Method Get -AuthorizationId "myToken"
            Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope It -ParameterFilter { $Uri -match "\?authorizationId=myToken&" } -ModuleName CloudDeploymentFramework
        }
    }
}
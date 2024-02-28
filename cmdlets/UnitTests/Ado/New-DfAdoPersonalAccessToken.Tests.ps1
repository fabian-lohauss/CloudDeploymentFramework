BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "New-DfAdoPersonalAccessToken" {
    BeforeAll {
    }

    Context "when not logged in" {
        BeforeAll {
            Mock New-DfBearerToken { throw "New-DfBearerToken: Run Connect-AzAccount to login." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Throw "Failed to create personal access token: New-DfBearerToken: Run Connect-AzAccount to login."
        }
    }

    Context "sign in popup" {
        BeforeAll {
            Mock New-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
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
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Throw "Failed to create personal access token: Sign in required. Run Connect-AzAccount to login."
        }
    }

    Context "expired token" {
        BeforeAll {
            Mock New-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                throw "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "displayName" } | Should -Throw "TF401444: Please sign-in at least once as 2cc4f755-24fa-4386-b120-80edcf8d499a\\user@something.onmicrosoft.com in a web browser to enable access to the service."
        }
    
    }

    Context "new PAT created successfully" {
        BeforeAll {
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName DeploymentFramework -Verifiable
            Mock New-DfBearerToken { return "" } -ModuleName DeploymentFramework -Verifiable
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                $Values = $Body | ConvertFrom-Json
                $Result = @{
                    patToken      = @{
                        displayName = $Values.displayName
                        validTo     = $Values.validTo
                        scope       = $Values.scope
                    }
                    patTokenError = "none"
                }
                return $Result
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the result" {
            $Pat = New-DfAdoPersonalAccessToken -organizationName "organizationName" -displayName "myNewPat"
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "app_token.manage"
        }
    }
}

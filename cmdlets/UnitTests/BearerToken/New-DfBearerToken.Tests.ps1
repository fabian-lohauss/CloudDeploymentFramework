BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "New-DfBearerToken" {
    BeforeAll {
        Mock Get-AzAccessToken { throw "should be mocked" } -ModuleName DeploymentFramework -Verifiable
    }

    Context "when not logged in" {
        BeforeAll {
            Mock Get-AzAccessToken { throw "Get-AzAccessToken: Run Connect-AzAccount to login." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfBearerToken } | Should -Throw "Failed to get bearer token: Get-AzAccessToken: Run Connect-AzAccount to login."
        }
    }

    Context "other error" {
        BeforeAll {
            Mock Get-AzAccessToken { throw "other error" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfBearerToken } | Should -Throw "Failed to get bearer token: other error"
        }
    }

    Context "already logged in" {
        BeforeAll {
            Mock Get-AzAccessToken { return @{ Token = "eyJ0eX" } } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the bearer token" {
            New-DfBearerToken | Should -Be "Bearer eyJ0eX"
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfBearerToken" {
    BeforeAll {
        Mock Get-AzAccessToken { throw "should be mocked" } -ModuleName DeploymentFramework -Verifiable
    }

    Context 'non-terminating error in Get-AzAccessToken ' {
        BeforeAll {
            Mock Get-AzAccessToken { if ("Stop" -eq $PesterBoundParameters.ErrorAction) { throw "non-terminating error" } } -ModuleName DeploymentFramework 
        }
    
        It 'Correctly processes non-terminating error from Get-AzAccessToken as exception message' {
            { Get-DfBearerToken } | Should -Throw "Failed to get bearer token: non-terminating error"
        }
    }

    Context "other exception" {
        BeforeAll {
            Mock Get-AzAccessToken { throw "other error" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { Get-DfBearerToken } | Should -Throw "Failed to get bearer token: other error"
        }
    }

    Context "already logged in" {
        BeforeAll {
            Mock Get-AzAccessToken { return @{ Token = "eyJ0eX" } } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the bearer token" {
            Get-DfBearerToken | Should -Be "Bearer eyJ0eX"
        }
    }
}
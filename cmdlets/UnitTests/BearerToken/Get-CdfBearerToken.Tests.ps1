BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfBearerToken" {
    BeforeAll {
        Mock Get-AzAccessToken { throw "should be mocked" } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context 'non-terminating error in Get-AzAccessToken ' {
        BeforeAll {
            Mock Get-AzAccessToken { if ("Stop" -eq $PesterBoundParameters.ErrorAction) { throw "non-terminating error" } } -ModuleName CloudDeploymentFramework 
        }
    
        It 'Correctly processes non-terminating error from Get-AzAccessToken as exception message' {
            { Get-CdfBearerToken } | Should -Throw "Failed to get bearer token: non-terminating error"
        }
    }

    Context "other exception" {
        BeforeAll {
            Mock Get-AzAccessToken { throw "other error" } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw" {
            { Get-CdfBearerToken } | Should -Throw "Failed to get bearer token: other error"
        }
    }

    Context "already logged in" {
        BeforeAll {
            Mock Get-AzAccessToken { return @{ Token = "eyJ0eX" } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the bearer token" {
            Get-CdfBearerToken | Should -Be "Bearer eyJ0eX"
        }
    }
}
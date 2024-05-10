BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Test-CdfSecret" {
    BeforeAll {
        Mock Get-CdfSecret { throw "should be mocked" } -ModuleName CloudDeploymentFramework
    }

    Context "secret exists" {
        BeforeAll {
            Mock Get-CdfSecret { return [PSCustomObject]@{ SecretValue = ("the secret" | ConvertTo-SecureString -AsPlainText ) } } -ModuleName CloudDeploymentFramework
        }

        It "should return true" {
           Test-CdfSecret -VaultName "myvault" -Name "mysecret" | Should -Be $true
        }
    }

    Context "secret does not exist" {
        BeforeAll {
            Mock Get-CdfSecret { } -ModuleName CloudDeploymentFramework
        }

        It "should return false" {
            Test-CdfSecret -VaultName "myvault" -Name "mysecret" | Should -Be $false
        }
    }


    Context "Get-CdfSecret throws" {
        BeforeAll {
            Mock Get-CdfSecret { throw "some error" } -ModuleName CloudDeploymentFramework
        }

        It "should rethrow the error" {
            { Test-CdfSecret -VaultName "myvault" -Name "mysecret" } | Should -Throw "some error"
        }
    }

    Context "parameter AllowKeyVaultNetworkRuleUpdate is set" {
        BeforeAll {
            Mock Get-CdfSecret {} -ModuleName CloudDeploymentFramework
        }

        It "should pass AllowKeyVaultNetworkRuleUpdate to Get-CdfSecret" {
            Test-CdfSecret -VaultName "myvault" -Name "mysecret" -AllowKeyVaultNetworkRuleUpdate
            Assert-MockCalled Get-CdfSecret -Exactly 1 -ParameterFilter { $AllowKeyVaultNetworkRuleUpdate -eq $true } -ModuleName CloudDeploymentFramework
        }
    }
}

BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Test-CdfContext" {
    BeforeAll {
        Mock Get-AzContext { throw "should be mocked" } -ModuleName CloudDeploymentFramework -Verifiable
        Mock az -ParameterFilter { ($args[0] -like "account") -and ($args[1] -eq "show" ) } { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "cli and cmdlet context connected" {
        BeforeAll {
            Mock Get-AzContext { return [PSCustomObject]@{ Name = "Context" } } -ModuleName CloudDeploymentFramework -Verifiable
            Mock az { if (($args[0] -eq "account") -and ($args[1] -eq "list") -and ($args[2] -eq "--only-show-errors") ) { return '{ Name: "Context" }' }; throw "unexpected parameter" } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return true" {
            Test-CdfContext | Should -BeTrue
            Should -Invoke az -Times 1 -ModuleName CloudDeploymentFramework 
            Should -Invoke Get-AzContext -Times 1 -ModuleName CloudDeploymentFramework
        }
    }

    Context "no cached context" {
        BeforeAll {
            Mock Get-AzContext { return $null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock az { if (($args[0] -eq "account") -and ($args[1] -eq "list" ) -and ($args[2] -eq "--only-show-errors") ) { return "[]" }; throw "unexpected parameter" } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return false" {
            Test-CdfContext | Should -BeFalse
            Should -Invoke az -Times 1 -ModuleName CloudDeploymentFramework 
            Should -Invoke Get-AzContext -Times 1 -ModuleName CloudDeploymentFramework
        }
    }
}
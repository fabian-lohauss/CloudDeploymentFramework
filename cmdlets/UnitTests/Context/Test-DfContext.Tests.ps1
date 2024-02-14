BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Test-DfContext" {
    BeforeAll {
        Mock Get-AzContext { throw "should be mocked" } -ModuleName DeploymentFramework -Verifiable
        Mock az -ParameterFilter { ($args[0] -like "account") -and ($args[1] -eq "show" ) } { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "cli and cmdlet context connected" {
        BeforeAll {
            Mock Get-AzContext { return [PSCustomObject]@{ Name = "Context" } } -ModuleName DeploymentFramework -Verifiable
            Mock az { if (($args[0] -eq "account") -and ($args[1] -eq "list") -and ($args[2] -eq "--only-show-errors") ) { return '{ Name: "Context" }' }; throw "unexpected parameter" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return true" {
            Test-DfContext | Should -BeTrue
            Should -Invoke az -Times 1 -ModuleName DeploymentFramework 
            Should -Invoke Get-AzContext -Times 1 -ModuleName DeploymentFramework
        }
    }

    Context "no cached context" {
        BeforeAll {
            Mock Get-AzContext { return $null } -ModuleName DeploymentFramework -Verifiable
            Mock az { if (($args[0] -eq "account") -and ($args[1] -eq "list" ) -and ($args[2] -eq "--only-show-errors") ) { return "[]" }; throw "unexpected parameter" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return false" {
            Test-DfContext | Should -BeFalse
            Should -Invoke az -Times 1 -ModuleName DeploymentFramework 
            Should -Invoke Get-AzContext -Times 1 -ModuleName DeploymentFramework
        }
    }
}
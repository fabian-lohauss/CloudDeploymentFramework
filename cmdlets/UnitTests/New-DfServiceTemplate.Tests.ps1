BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}


Describe "New-DfServiceTemplate" {
    Context "ParameterSet" {
        It "should have a mandatory name parameter" {
            Get-Command -Name New-DfServiceTemplate | Should -HaveParameter Name -Mandatory 
        }            
    }

    Context "return object" {
        It "should have property 'Name'" {
            (New-DfServiceTemplate -Name "AService" | Get-Member -MemberType NoteProperty).Name | Should -Contain "Name"
        }
    }
}
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
        BeforeAll {
            $sut = New-DfServiceTemplate -Name "AService"
        }

        It "should have '<PropertyName>=<ExpectedValue>'" -TestCases @(
            @{ PropertyName = "Name"; ExpectedValue = "AService"}
            @{ PropertyName = "Version"; ExpectedValue = "1.0-PreRelease"} 
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -Be $ExpectedValue
        }

    }
}
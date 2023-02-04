BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}


Describe "New-DfComponent" {
    Context "ParameterSet" {
        It "should have a mandatory name parameter" {
            Get-Command -Name New-DfComponent | Should -HaveParameter Name -Mandatory
        }            
    }

    Context "happy path" {
        BeforeAll {
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ Library = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
            $sut = New-DfComponent "Something"
        }

        It "should return only the component" {
            $sut | Should -HaveCount 1
        }

        It "should have the <PropertyName>=<ExpectedValue>" -TestCases @(
            @{ PropertyName = "Path"; ExpectedValue = "TestDrive:/Components/Something" }
            @{ PropertyName = "Name"; ExpectedValue = "Something" }
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -Be $ExpectedValue
            Should -InvokeVerifiable
        }

        It "should create the component folder in the library" {
            (Get-ChildItem TestDrive:/Components -Directory).Name | Should -Contain "Something"
        }
    }
}
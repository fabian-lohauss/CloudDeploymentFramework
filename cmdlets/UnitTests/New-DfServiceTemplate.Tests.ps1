BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}


Describe "New-DfServiceTemplate" {
    BeforeAll {
        Mock Get-DfProject { return New-Object PSCustomObject -Property @{ ServicesPath = "TestDrive:/Services" } } -ModuleName DeploymentFramework
    }

    Context "ParameterSet" {
        It "should have a mandatory name parameter" {
            Get-Command -Name New-DfServiceTemplate | Should -HaveParameter Name -Mandatory 
        }            
    }

    Context "return object" {
        BeforeAll {
            $sut = New-DfServiceTemplate -Name "AService"
        }

        It "should return one object" {
            $sut | Should -HaveCount 1
        }

        It "should have '<PropertyName>=<ExpectedValue>'" -TestCases @(
            @{ PropertyName = "Name"; ExpectedValue = "AService" }
            @{ PropertyName = "Path"; ExpectedValue = "TestDrive:/Services/AService/v1.0" }
            @{ PropertyName = "Version"; ExpectedValue = "1.0-PreRelease" } 
            @{ PropertyName = "PreRelease"; ExpectedValue = $true } 
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -Be $ExpectedValue
        }
    }

    Context "persistent file" {
        BeforeAll {
            $sut = New-DfServiceTemplate -Name "AService"
        }
        
        It "should create a service template folder" {
            (Get-ChildItem "TestDrive:/Services" -Directory).Name | Should -Contain "AService"
            (Get-ChildItem "TestDrive:/Services/AService" -Directory).Name | Should -Contain "v1.0"
        }
    }
}
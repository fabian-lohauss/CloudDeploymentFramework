BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -Force
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
            New-DfServiceTemplate -Name "AService" -OutVariable sut
        }

        It "should return one object" {
            $sut | Should -HaveCount 1
        }

        It "should have property [<ExpectedType>]<PropertyName>" -TestCases @(
            @{ PropertyName = "Name"; ExpectedType = [string] }
            @{ PropertyName = "Path"; ExpectedType = [string] }
            @{ PropertyName = "Version"; ExpectedType = [string] } 
            @{ PropertyName = "PreRelease"; ExpectedType = [bool] } 
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -BeOfType $ExpectedType
        }

        It "should have component as list" {
            $sut | Get-Member Component | Should -be "System.Collections.ArrayList Component="
        }

        It "should have value '<PropertyName>=<ExpectedValue>'" -TestCases @(
            @{ PropertyName = "Name"; ExpectedValue = "AService" }
            @{ PropertyName = "Path"; ExpectedValue = "TestDrive:/Services/AService/v1.0" }
            @{ PropertyName = "Version"; ExpectedValue = "1.0-PreRelease" } 
            @{ PropertyName = "PreRelease"; ExpectedValue = $true } 
        ) {
            $sut.$PropertyName | Should -Be $ExpectedValue
        }
    }

    Context "persistent file" {
        BeforeAll {
            New-DfServiceTemplate -Name "AService" -OutVariable sut
        }
        
        It "should create a service template folder" {
            (Get-ChildItem "TestDrive:/Services" -Directory).Name | Should -Contain "AService"
            (Get-ChildItem "TestDrive:/Services/AService" -Directory).Name | Should -Contain "v1.0"
        }

        It "should create the service template file" {
            (Get-ChildItem "TestDrive:/Services/AService/v1.0").Name | Should -Contain "AService.json"
        }

        It "should create the default bicep" {
            (Get-ChildItem "TestDrive:/Services/AService/v1.0").Name | Should -Contain "AService.bicep"
        }
    }
}
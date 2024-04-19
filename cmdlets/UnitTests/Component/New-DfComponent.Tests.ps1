BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}


Describe "New-CdfComponent" {
    Context "ParameterSet" {
        It "should have a mandatory name parameter" {
            Get-Command -Name New-CdfComponent | Should -HaveParameter Name -Mandatory
        }            

        It "should have a mandatory type parameter" {
            Get-Command -Name New-CdfComponent | Should -HaveParameter Type -Mandatory 
        }            
    }

    Context "happy path" {
        BeforeAll {
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
            $sut = New-CdfComponent "Something" -Type Bicep
        }

        It "should return only the component" {
            $sut | Should -HaveCount 1
        }

        It "should have the <PropertyName>=<ExpectedValue>" -TestCases @(
            @{ PropertyName = "Path"; ExpectedValue = ("TestDrive:", "Components", "Something", "v1.0", "Something.bicep" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "Name"; ExpectedValue = "Something" }
            @{ PropertyName = "Version"; ExpectedValue = "1.0-PreRelease" }
            @{ PropertyName = "PreRelease"; ExpectedValue = $true }
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -BeExactly $ExpectedValue
            Should -InvokeVerifiable
        }

        It "should create the component folder in the ComponentsPath" {
            (Get-ChildItem TestDrive:/Components -Directory).Name | Should -Contain "Something"
        }

        It "should create the version folder under the component folder" {
            (Get-ChildItem TestDrive:/Components/Something -Directory).Name | Should -Contain "v1.0"
        }
    }
}
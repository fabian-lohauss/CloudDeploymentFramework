BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Get-DfComponent" {
    Context "single component" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0" -ItemType Directory -Force | Out-Null
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should return the component" {
            $sut = Get-DfComponent
            $sut.Name | Should -Be "TheComponent"
            $sut.Version | Should -Be "1.0"
        }
    }

    Context "filter by name" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0" -ItemType Directory -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v1.1" -ItemType Directory -Force | Out-Null
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should return the component" -TestCases @(
            @{ GivenName = "TheComponent"; ExpectedName = "TheComponent"; ExpectedVersion = "1.0" }
            @{ GivenName = "OtherComponent"; ExpectedName = "OtherComponent"; ExpectedVersion = "1.1" }
        ) {
            $sut = Get-DfComponent $GivenName
            $sut.Name | Should -Be $ExpectedName
            $sut.Version | Should -Be $ExpectedVersion
        }
    }
}
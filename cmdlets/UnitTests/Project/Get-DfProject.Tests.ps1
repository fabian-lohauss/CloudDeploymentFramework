BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -Force
}

Describe "Get-DfProject" {
    Context "return object" {
        BeforeAll {
            Mock Find-DfProjectFolder { return New-Object -Type PSCustomObject -Property @{ FullName = "TestDrive:/" } } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the base path" -TestCases @(
            @{ PropertyName = "Path"; ExpectedValue = "TestDrive:/" }
            @{ PropertyName = "ComponentsPath"; ExpectedValue = "TestDrive:/Components" }
            @{ PropertyName = "ServicesPath"; ExpectedValue = "TestDrive:/Services" }
        ) {
            (Get-DfProject).$PropertyName | Should -Be $ExpectedValue
            Should -InvokeVerifiable
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Deploy-DfComponent" {
    Context "Parameter set" {
        It "should have parameter '<ExpectedParameter>'" -TestCases @(
            @{ ExpectedParameter = "Name" }
            @{ ExpectedParameter = "Version" }
            @{ ExpectedParameter = "ResourceGroupName" }
         ) {
            Get-Command Deploy-DfComponent  | Should -HaveParameter $ExpectedParameter -Mandatory
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Deploy-DfService" {
    BeforeAll {
        Mock New-AzResourceGroupDeployment { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have a '<ExpectedParameter>' parameter" -TestCases @(
#            @{ ExpectedParameter = 'Name' }
        ) {
            Get-Command Deploy-DfService | Should -HaveParameter $ExpectedParameter
        }
    }

    Context "happy path" {
        It "should deploy the bicep file" {
            Deploy-DfService
            Should -InvokeVerifiable
        }
    }
}
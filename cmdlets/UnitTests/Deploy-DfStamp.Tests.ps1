BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Deploy-DfStamp" {
    Context "happy path" {
        BeforeAll {
            Mock New-AzDeployment {} -ModuleName DeploymentFramework -Verifiable
        }

        It "should create the resource group" {
            New-Object PSCustomObject -Property @{ Name="stamp" } | Deploy-DfStamp
            Should -InvokeVerifiable
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Deploy-CdfStamp" {
    Context "happy path" {
        BeforeAll {
            Mock New-AzDeployment {} -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should create the resource group" {
            New-Object PSCustomObject -Property @{ Name="stamp" } | Deploy-CdfStamp
            Should -InvokeVerifiable
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Get-DfProject" {
    Context "valid project folder" {
        BeforeAll {
            Mock Find-DfProjectFolder { return "TestDrive:/" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the base path" {
            (Get-DfProject).Folder | Should -Be "TestDrive:/"  
            Should -InvokeVerifiable
        }
    }
}
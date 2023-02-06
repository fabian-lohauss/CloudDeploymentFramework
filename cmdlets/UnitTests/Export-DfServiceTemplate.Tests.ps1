BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Export-DfServiceTemplate" {
    Context "happy path" {
        It "should not throw" {
            { Export-DfServiceTemplate -Path "TestDrive:/Services/" } | Should -Not -Throw
        }
    }
}
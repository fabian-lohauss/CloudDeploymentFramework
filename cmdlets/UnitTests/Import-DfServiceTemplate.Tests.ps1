BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Import-DfServiceTemplate" {
    Context "happy path" {
        It "should not throw" {
            { Import-DfServiceTemplate } | Should -Not -Throw
        }
    }
}
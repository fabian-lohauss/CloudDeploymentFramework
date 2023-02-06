BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Get-DfComponent" {
    Context "happy path" {
        It "should not throw" {
            { Get-DfComponent } | Should -Not -Throw
        }
    }
}
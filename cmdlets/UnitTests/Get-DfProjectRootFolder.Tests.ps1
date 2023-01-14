BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -force
}

Describe "Get-DfProjectRootFolder" {
    Context "not project root" {
        It "should throw" {
           { Get-DfProjectRootFolder } | Should -Throw -ExpectedMessage "Failed to find DeploymentFramework project root folder"
        }
    }
}
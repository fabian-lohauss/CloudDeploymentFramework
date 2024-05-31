BeforeAll {
    Import-Module $PSScriptRoot/../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Test-CdfDeploymentPipeline" {
    BeforeAll {
        Mock Test-Path { return $false } -ModuleName CloudDeploymentFramework -Verifiable
        Mock Get-Item { return @{ Value = "True" } } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "result schema" {
        It "should return true if in ADO pipeline" {
            Mock Test-Path -ParameterFilter { $Path -eq "env:/TF_BUILD" } { return $true } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Item -ParameterFilter { $Path -eq "env:/TF_BUILD" } { return @{ Value = "True" } } -ModuleName CloudDeploymentFramework -Verifiable
            Test-CdfDeploymentPipeline | Should -Be $true
        }

        It "should return false if env:/HOST_TF_BUILD is not set" {
            Mock Test-Path -ParameterFilter { $Path -eq "env:/TF_BUILD" } { return $false } -ModuleName CloudDeploymentFramework -Verifiable
            Test-CdfDeploymentPipeline | Should -Be $false
        }

        It "should return true if in GitHub pipeline" {
            Mock Test-Path -ParameterFilter { $Path -eq "env:/GITHUB_ACTIONS" } { return $true } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-Item -ParameterFilter { $Path -eq "env:/GITHUB_ACTIONS" } { return @{ Value = "True" } } -ModuleName CloudDeploymentFramework -Verifiable
            Test-CdfDeploymentPipeline | Should -Be $true
        }

        It "should return false if env:/GITHUB_ACTIONS is not set" {
            Mock Test-Path -ParameterFilter { $Path -eq "env:/GITHUB_ACTIONS" } { return $false } -ModuleName CloudDeploymentFramework -Verifiable
            Test-CdfDeploymentPipeline | Should -Be $false
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Add-DfEnvironment" {
    Context "happy path" {
        BeforeAll {
            Mock Get-DfProject { return @{ Path = "TestDrive:/" } } -ModuleName DeploymentFramework
            New-Item -Path "TestDrive:/.df/Configuration.json" -Value "{}" -Force

            Add-DfEnvironment -Name "dev" -Subscription "123-456"
        }

        It "should add the environment to the configuration file" {
            $Config = (Get-Content "TestDrive:/.df/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456"
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -Force
}

Describe "Add-DfEnvironment" {
    BeforeAll {
        Mock Get-DfProject { return @{ Path = "TestDrive:/" } } -ModuleName DeploymentFramework
        New-Item -Path "TestDrive:/.df/Configuration.json" -Value "{}" -Force
    }

    Context "parameterset" {
        It "should have mandatory parameter 'name'" {
            Get-Command Add-DfEnvironment | Should -HaveParameter Name -Mandatory
        }
    }

    Context "happy path" {
        It "should add the environment to the configuration file" {
            Add-DfEnvironment -Name "dev" -Subscription "123-456"
            $Config = (Get-Content "TestDrive:/.df/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456"
        }
    }

    Context "from name by pipeline" {
        It "should add the environment to the configuration file" {
            [PSCustomObject]@{ Id = "123-456-789" } | Add-DfEnvironment -Name "dev"
            $Config = (Get-Content "TestDrive:/.df/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456-789"
        }
    }
}
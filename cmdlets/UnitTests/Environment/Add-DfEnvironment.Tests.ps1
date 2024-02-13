BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
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

        It "should have mandatory parameter 'id'" {
            Get-Command Add-DfEnvironment | Should -HaveParameter Id -Mandatory -InParameterSet UseSubscription
        }

        It "should have parameter CurrentAzureContext" {
            Get-Command Add-DfEnvironment | Should -HaveParameter CurrentAzureContext -Mandatory -InParameterSet UseCurrentAzureContext
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

    Context "with CurrentAzureContext" {
        BeforeAll {
            Mock Get-AzContext { return @{ Subscription = @{ Id= "123-456" } } } -ModuleName DeploymentFramework
        }

        It "should add the environment to the configuration file" {
            Add-DfEnvironment -Name "dev" -CurrentAzureContext
            $Config = (Get-Content "TestDrive:/.df/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456"
        }
    }
}
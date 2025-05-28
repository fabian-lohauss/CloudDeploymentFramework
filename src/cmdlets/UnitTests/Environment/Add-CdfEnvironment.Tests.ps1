BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Add-CdfEnvironment" {
    BeforeAll {
        Mock Get-CdfProject { return @{ Path = "TestDrive:/" } } -ModuleName CloudDeploymentFramework
        New-Item -Path "TestDrive:/.cdf/Configuration.json" -Value "{}" -Force
    }

    Context "parameterset" {
        It "should have mandatory parameter 'name'" {
            Get-Command Add-CdfEnvironment | Should -HaveParameter Name -Mandatory
        }

        It "should have mandatory parameter 'id'" {
            Get-Command Add-CdfEnvironment | Should -HaveParameter Id -Mandatory -InParameterSet UseSubscription
        }

        It "should have parameter CurrentAzureContext" {
            Get-Command Add-CdfEnvironment | Should -HaveParameter CurrentAzureContext -Mandatory -InParameterSet UseCurrentAzureContext
        }
    }

    Context "happy path" {
        It "should add the environment to the configuration file" {
            Add-CdfEnvironment -Name "dev" -Subscription "123-456"
            $Config = (Get-Content "TestDrive:/.cdf/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456"
        }
    }

    Context "from name by pipeline" {
        It "should add the environment to the configuration file" {
            [PSCustomObject]@{ Id = "123-456-789" } | Add-CdfEnvironment -Name "dev"
            $Config = (Get-Content "TestDrive:/.cdf/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456-789"
        }
    }

    Context "with CurrentAzureContext" {
        BeforeAll {
            Mock Get-AzContext { return @{ Subscription = @{ Id= "123-456" } } } -ModuleName CloudDeploymentFramework
        }

        It "should add the environment to the configuration file" {
            Add-CdfEnvironment -Name "dev" -CurrentAzureContext
            $Config = (Get-Content "TestDrive:/.cdf/Configuration.json" | ConvertFrom-Json)
            $Config.Environment.dev.Subscription | Should -Be "123-456"
        }
    }
}
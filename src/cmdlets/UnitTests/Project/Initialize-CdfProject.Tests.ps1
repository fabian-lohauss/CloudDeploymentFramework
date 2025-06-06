BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Initialize-CdfProject" {

    Context "Parameter set" {
        It "should have a mandatory parameter 'Name'" {
            (Get-Command Initialize-CdfProject) | Should -HaveParameter "Name" -Mandatory
        }
    }

    Context "current folder not initialized" {
        BeforeAll {
            Push-Location "TestDrive:/"
            $sut = Initialize-CdfProject -Name "Project"
        }

        AfterAll {
            Pop-Location
        }

        It "should create the .cdf folder" {
            (Test-Path "TestDrive:/.cdf" -PathType Container) | Should -Be $true
        }

        It "should create the configuration file" {
            (Get-ChildItem "TestDrive:/.cdf").Name | Should -Contain "Configuration.json"
        }
    }

    Context "configuration file" {
        BeforeAll {
            Push-Location "TestDrive:/"
            Initialize-CdfProject -Name "Project"
            $sut = Get-Content "TestDrive:/.cdf/Configuration.json" | ConvertFrom-Json
        }

        AfterAll {
            Pop-Location
        }

        It "should create a json file for configuration with the name of the project" {
            $Sut.Name | Should -Be "Project"
        }
    }

    Context "output" {
        BeforeAll {
            Push-Location "TestDrive:/"
            $sut = Initialize-CdfProject -Name "Project" 
        }

        AfterAll {
            Pop-Location
        }
        
        It "should not have output" {
            $sut | Should -Be $null
        }

        It "should not throw" {
            { Initialize-CdfProject -Name "Project" } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Initialize-CdfProject -Name "Project" 
            $Error | Should -Be $null
        }
    }

    Context "current folder already initialized" {
        BeforeAll {
            New-Item -Path "TestDrive:/.cdf" -Name "Configuration.json" -ItemType File -Value "@{ }" -Force | Out-Null
            Push-Location "TestDrive:/"
            $sut = Initialize-CdfProject -Name "Project"
        }

        AfterAll {
            Pop-Location
        }

        It "should keep the .cdf folder" {
            (Test-Path "TestDrive:/.cdf" -PathType Container) | Should -Be $true
        }
    }
}
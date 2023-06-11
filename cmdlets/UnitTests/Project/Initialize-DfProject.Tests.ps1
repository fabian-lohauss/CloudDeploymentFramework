BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -Force
}

Describe "Initialize-DfProject" {

    Context "Parameter set" {
        It "should have a parameter set named 'Default'" {
            (Get-Command Initialize-DfProject).ParameterSets.Name | Should -Contain "Default"
        }

        It "should have a mandatory parameter 'Name'" {
            (Get-Command Initialize-DfProject) | Should -HaveParameter "Name" -Mandatory
        }
    }

    Context "current folder not initialized" {
        BeforeAll {
            Push-Location "TestDrive:/"
            Initialize-DfProject -Name "Project" -OutVariable sut
        }

        AfterAll {
            Pop-Location
        }

        It "should create the .df folder" {
            (Get-ChildItem "TestDrive:/" -Hidden).Name | Should -Contain ".df"
        }

        It "should create the configuration file" {
            (Get-ChildItem "TestDrive:/.df").Name | Should -Contain "Configuration.json"
        }

        It "should create a json file for configuration" {
            ( Get-Content "TestDrive:/.df/Configuration.json" | ConvertFrom-Json ) | Should -Not -Be $null
        }

        It "should not have output" {
            $Sut | Should -Be $null
        }
    }

    Context "current folder already initialized" {
        BeforeAll {
            New-Item -Path "TestDrive:/.df" -Name "Configuration.json" -ItemType File -Value "@{ }" -Force | Out-Null
            Push-Location "TestDrive:/"
        }

        AfterAll {
            Pop-Location
        }

        It "should keep the .df folder" {
            Initialize-DfProject -Name "Project"
            (Get-ChildItem "TestDrive:/" -Hidden).Name | Should -Contain ".df"
        }

        It "should not have output" {
            Initialize-DfProject -Name "Project" | Should -Be $null
        }

        It "should not throw" {
            { Initialize-DfProject -Name "Project" } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Initialize-DfProject -Name "Project" 
            $Error | Should -Be $null
        }
    }
}
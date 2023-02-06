BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -force
}

Describe "Initialize-DfProject" {

    Context "current folder not initialized" {
        BeforeAll {
            Push-Location "TestDrive:/"
            Initialize-DfProject -OutVariable sut
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
            Initialize-DfProject
            (Get-ChildItem "TestDrive:/" -Hidden).Name | Should -Contain ".df"
        }

        It "should not have output" {
            Initialize-DfProject | Should -Be $null
        }

        It "should not throw" {
            { Initialize-DfProject } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Initialize-DfProject
            $Error | Should -Be $null
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -force
}

Describe "Initialize-DfProject" {

    Context "current folder not initialized" {
        BeforeAll {
            Push-Location "TestDrive:/"
            $Sut = Initialize-DfProject
        }

        AfterAll {
            Pop-Location
        }

        It "should create the .df folder" {
            (Get-ChildItem "TestDrive:/" -Hidden).Name | Should -Contain ".df"
        }

        It "should not have output" {
            $Sut | Should -Be $null
        }
    }

    Context "current folder initialized" {
        BeforeAll {
            New-Item -Path "TestDrive:/" -Name ".df" -ItemType Directory | Out-Null
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
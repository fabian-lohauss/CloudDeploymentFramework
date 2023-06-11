BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -force
}

Describe "Find-DfProjectFolder" {
    Context "valid project folder <GivenFolders>" -ForEach @(
        @{ GivenFolders = @("TestDrive:/.df"); GivenWorkingDirectory = "TestDrive:/"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/.df", "TestDrive:/SomeFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/.df", "TestDrive:/SomeFolder/OtherFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/OtherFolder"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/SomeFolder/.df"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedFolder = "TestDrive:/SomeFolder" }
        @{ GivenFolders = @("TestDrive:/SomeFolder/.df", "TestDrive:/SomeFolder/OtherFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/OtherFolder"; ExpectedFolder = "TestDrive:/SomeFolder" }
    ) {
        BeforeAll {
            foreach ($GivenFolder in $GivenFolders) {
                New-Item -Path $GivenFolder -ItemType Directory | Out-Null
            }
        }

        BeforeEach {
            Push-Location $GivenWorkingDirectory
        }
        
        AfterEach {
            Pop-Location
        }

        It "should return a System.IO.DirectoryInfo" {
            (Find-DfProjectFolder) | Should -BeOfType System.IO.DirectoryInfo
        }

        It "should return the project folder '$ExpectedFolder'" {
            (Find-DfProjectFolder).FullName | Should -Be (Get-Item $ExpectedFolder).FullName
        }
    }

    Context "no project folder <GivenFolders>" -ForEach @(
        @{ GivenFolders = @(); GivenWorkingDirectory = "TestDrive:/"; ExpectedMessage = "Failed to find DeploymentFramework project folder in 'TestDrive:/'" }
        @{ GivenFolders = @("TestDrive:/SomeFolder", "TestDrive:/OtherFolder/.df"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedMessage = "Failed to find DeploymentFramework project folder in 'TestDrive:/SomeFolder'" }
        @{ GivenFolders = @("TestDrive:/SomeFolder/AFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/AFolder"; ExpectedMessage = "Failed to find DeploymentFramework project folder in 'TestDrive:/SomeFolder/AFolder'" }
    ) {
        BeforeEach {
            foreach ($GivenFolder in $GivenFolders) {
                New-Item -Path $GivenFolder -ItemType Directory | Out-Null
            }
            Push-Location $GivenWorkingDirectory
        }

        AfterEach {
            Pop-Location
        }

        It "should throw" {
            { Find-DfProjectFolder } | Should -Throw -ExpectedMessage $ExpectedMessage
        }
    }
}
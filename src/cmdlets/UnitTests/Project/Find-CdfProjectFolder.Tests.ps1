BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -force
}

Describe "Find-CdfProjectFolder" {
    Context "valid project folder <GivenFolders>" -ForEach @(
        @{ GivenFolders = @("TestDrive:/.cdf"); GivenWorkingDirectory = "TestDrive:/"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/.cdf", "TestDrive:/SomeFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/.cdf", "TestDrive:/SomeFolder/OtherFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/OtherFolder"; ExpectedFolder = "TestDrive:/" }
        @{ GivenFolders = @("TestDrive:/SomeFolder/.cdf"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedFolder = "TestDrive:/SomeFolder" }
        @{ GivenFolders = @("TestDrive:/SomeFolder/.cdf", "TestDrive:/SomeFolder/OtherFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/OtherFolder"; ExpectedFolder = "TestDrive:/SomeFolder" }
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
            (Find-CdfProjectFolder) | Should -BeOfType System.IO.DirectoryInfo
        }

        It "should return the project folder '$ExpectedFolder'" {
            (Find-CdfProjectFolder).FullName | Should -Be (Get-Item $ExpectedFolder).FullName
        }
    }

    Context "no project folder <GivenFolders>" -ForEach @(
        @{ GivenFolders = @(); GivenWorkingDirectory = "TestDrive:/"; ExpectedMessage = ("Failed to find CloudDeploymentFramework project folder in '{0}'" -f ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar)) }
        @{ GivenFolders = @("TestDrive:/SomeFolder", "TestDrive:/OtherFolder/.cdf"); GivenWorkingDirectory = "TestDrive:/SomeFolder"; ExpectedMessage =  ("Failed to find CloudDeploymentFramework project folder in '{0}'" -f ("TestDrive:", "SomeFolder" -join [System.IO.Path]::DirectorySeparatorChar)) }
        @{ GivenFolders = @("TestDrive:/SomeFolder/AFolder"); GivenWorkingDirectory = "TestDrive:/SomeFolder/AFolder"; ExpectedMessage = ("Failed to find CloudDeploymentFramework project folder in '{0}'" -f ("TestDrive:", "SomeFolder", "AFolder" -join [System.IO.Path]::DirectorySeparatorChar)) }
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
            { Find-CdfProjectFolder } | Should -Throw -ExpectedMessage $ExpectedMessage
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfStampTemplate" {
    Context "valid templates '<GivenFolders>'" -ForEach @(
        @{ GivenFolders = @("TestDrive:/Stamps/AStamp"); ExpectedTemplates = @( @{ Name = "AStamp" } ) }
        @{ GivenFolders = @("TestDrive:/Stamps/AStamp", "TestDrive:/Stamps/SecondStamp"); ExpectedTemplates = @( @{ Name = "AStamp" }, @{ Name = "SecondStamp" } ) }
    ) {
        BeforeAll {
            foreach ($Folder in $GivenFolders) {
                New-Item $Folder -ItemType Directory -Force | Out-Null
            }
            Mock Get-CdfProject { return @{ StampFolder = "TestDrive:/Stamps" } } -ModuleName CloudDeploymentFramework
        }

        It "should not throw" {
            { Get-CdfStampTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-CdfStampTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return the expected number of templates" {
            Get-CdfStampTemplate | Should -HaveCount $ExpectedTemplates.Count
            Should -Invoke Get-CdfProject -ModuleName CloudDeploymentFramework
        }

        It "should return the template '<Name>'" -TestCases $ExpectedTemplates {
            (Get-CdfStampTemplate).Name | Should -Contain $Name
            Should -Invoke Get-CdfProject -ModuleName CloudDeploymentFramework
        }
    }

    Context "no templates" -ForEach @(
        @{ GivenFolders = @() }
        @{ GivenFolders = @("TestDrive:/Stamps") }
    ) {
        BeforeAll {
            foreach ($Folder in $GivenFolders) {
                New-Item $Folder -ItemType Directory -Force | Out-Null
            }
            Mock Get-CdfProject { return @{ StampFolder = "TestDrive:/Stamps" } } -ModuleName CloudDeploymentFramework
        }

        It "should not throw" {
            { Get-CdfStampTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-CdfStampTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return null" {
            Get-CdfStampTemplate | Should -Be $null
            Should -Invoke Get-CdfProject -ModuleName CloudDeploymentFramework
        }
    }    
}
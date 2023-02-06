BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Get-DfServiceTemplate" {

    Context "return object" -ForEach @(
        @{ GivenFilename = "TestDrive:/Services/SecondService/v2.1/SecondService.json"; GivenContent = '{ "Name": "SecondService", "Version": "2.1-PreRelease", "PreRelease": true, "Component": { "OtherComponent": "1.3"} }'; GivenFilter = "SecondService" }
        #  @{ GivenFolders = @("TestDrive:/Services/AService/v1.1", "TestDrive:/Services/SecondService/v2.0"); GivenName = "SecondService" }
    ) {
        BeforeAll {
            Mock Get-DfProject { return @{ ServicesPath = "TestDrive:/Services" } } -ModuleName DeploymentFramework
            New-Item $GivenFilename -ItemType File -Value $GivenContent -Force | Out-Null

            Get-DfServiceTemplate -Name $GivenFilter -OutVariable sut
        }

        It "should return one object" {
            $sut | Should -HaveCount 1
        }

        It "should have property [<ExpectedType>]<PropertyName>" -TestCases @(
            @{ PropertyName = "Name"; ExpectedType = [string] }
            @{ PropertyName = "Path"; ExpectedType = [string] }
            @{ PropertyName = "Version"; ExpectedType = [string] } 
            @{ PropertyName = "PreRelease"; ExpectedType = [bool] } 
            @{ PropertyName = "Component"; ExpectedType = [PSCustomObject] } 
        ) {
            ($sut | Get-Member -MemberType NoteProperty).Name | Should -Contain $PropertyName
            $sut.$PropertyName | Should -BeOfType $ExpectedType
        }

        It "should have value '<PropertyName>=<ExpectedValue>'" -TestCases @(
            @{ PropertyName = "Name"; ExpectedValue = "SecondService" }
            @{ PropertyName = "Version"; ExpectedValue = "2.1-PreRelease" } 
            @{ PropertyName = "PreRelease"; ExpectedValue = $true } 
        ) {
            $sut.$PropertyName | Should -Be $ExpectedValue
        }

        It "should have the expected path value" {
            $sut.Path | Should -Be (Get-Item "TestDrive:/Services/SecondService/v2.1").FullName
        }
    }

    Context "valid templates '<GivenFolders>'" -ForEach @(
        @{ 
            GivenFilename = "TestDrive:/Services/SecondService/v2.1/SecondService.json"; GivenContent = '{ "Name": "SecondService", "Version": "2.1", "Component": { "OtherComponent": "1.3"} }'; GivenFilter = "SecondService" 
        }
    ) {
        BeforeAll {
            New-Item $GivenFilename -ItemType File -Value $GivenContent -Force | Out-Null

            Mock Get-DfProject { return @{ ServicesPath = "TestDrive:/Services" } } -ModuleName DeploymentFramework
        }

        It "should not throw" {
            { Get-DfServiceTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-DfServiceTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return the expected number of templates" {
            Get-DfServiceTemplate | Should -HaveCount 1
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }

        It "should return the template '<Name>'" -TestCases $ExpectedTemplates {
            (Get-DfServiceTemplate).Name | Should -Contain $Name
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }
    }

    Context "no templates" -ForEach @(
        @{ GivenFolders = @() }
        @{ GivenFolders = @("TestDrive:/Services") }
    ) {
        BeforeAll {
            foreach ($Folder in $GivenFolders) {
                New-Item $Folder -ItemType Directory -Force | Out-Null
            }
            Mock Get-DfProject { return @{ ServicesPath = "TestDrive:/Services" } } -ModuleName DeploymentFramework
        }

        It "should not throw" {
            { Get-DfServiceTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-DfServiceTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return null" {
            Get-DfServiceTemplate | Should -Be $null
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }
    }    
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfComponent" {
    Context "single component" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" -ItemType File -Force | Out-Null
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should return the component" {
            $sut = Get-DfComponent
            $sut.Name | Should -Be "TheComponent"
            $sut.Version | Should -Be "1.0" 
            $sut.Path | Should -Be (Resolve-Path "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep").ProviderPath
            $sut.Type | Should -Be "Bicep"
        }
    }

    Context "multiple files" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/TheComponent/v1.1/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v2.0/OtherComponent.bicep" -ItemType File -Force | Out-Null

            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
            $sut = Get-DfComponent
        }

        It "should return an array" {
            $sut | Should -HaveCount 3
        }

        It "should return the component <Name> <Version>" -ForEach @(
            @{ Name = "TheComponent"; Version = "1.0"; Path = "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" } 
            @{ Name = "TheComponent"; Version = "1.1"; Path = "TestDrive:/Components/TheComponent/v1.1/TheComponent.bicep" } 
            @{ Name = "OtherComponent"; Version = "2.0"; Path = "TestDrive:/Components/OtherComponent/v2.0/OtherComponent.bicep" } 
        ) {
            $sut | Where-Object { $_.Name -eq $Name -and $_.Version -eq $Version -and $_.Path -eq (Resolve-Path $Path).ProviderPath } | Should -Not -BeNullOrEmpty
        }
    }

    Context "filter by name" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v1.1/OtherComponent.bicep" -ItemType File -Force | Out-Null
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should return the component" -TestCases @(
            @{ GivenName = "TheComponent"; ExpectedName = "TheComponent"; ExpectedVersion = "1.0" }
            @{ GivenName = "OtherComponent"; ExpectedName = "OtherComponent"; ExpectedVersion = "1.1" }
        ) {
            $sut = Get-DfComponent $GivenName
            $sut.Name | Should -Be $ExpectedName
            $sut.Version | Should -Be $ExpectedVersion
        }
    }
}
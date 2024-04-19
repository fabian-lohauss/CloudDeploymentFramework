BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfComponent" {
    Context "Parameter set" {
        It "should have parameter '<ExpectedParameter>'" -TestCases @(
            @{ ExpectedParameter = "Name" }
            @{ ExpectedParameter = "Version" }
        ) {
            Get-Command Get-CdfComponent  | Should -HaveParameter $ExpectedParameter 
        }
    }
    
    Context "single component" {
        BeforeAll {
            New-Item "TestDrive:/Components/AComponent/v2.0/AComponent.bicep" -ItemType File -Force | Out-Null
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
        }
        
        It "should return the component" {
            $sut = Get-CdfComponent
            $sut.Name | Should -Be "AComponent"
            $sut.Version | Should -Be "2.0" 
            $sut.Path | Should -Be (Resolve-Path "TestDrive:/Components/AComponent/v2.0/AComponent.bicep").ProviderPath
            $sut.Type | Should -Be "Bicep"
        }
    }

    Context "multiple components" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/TheComponent/v1.1/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v2.0/OtherComponent.bicep" -ItemType File -Force | Out-Null

            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
            $sut = Get-CdfComponent
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
            New-Item "TestDrive:/Components/TheComponent/v1.1/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v1.1/OtherComponent.bicep" -ItemType File -Force | Out-Null
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
        }
        
        It "should return the component" -TestCases @(
            @{ GivenName = "TheComponent"; ExpectedName = @("TheComponent", "TheComponent"); ExpectedVersion = @("1.0", "1.1") }
            @{ GivenName = "OtherComponent"; ExpectedName = "OtherComponent"; ExpectedVersion = "1.1" }
        ) {
            $sut = Get-CdfComponent $GivenName
            $sut.Name | Should -Be $ExpectedName
            $sut.Version | Should -Be $ExpectedVersion
        }
    }

    Context "filter by name and version" {
        BeforeAll {
            New-Item "TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/TheComponent/v1.1/TheComponent.bicep" -ItemType File -Force | Out-Null
            New-Item "TestDrive:/Components/OtherComponent/v1.1/OtherComponent.bicep" -ItemType File -Force | Out-Null
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
        }
        
        It "should return the component" -TestCases @(
            @{ GivenName = "TheComponent"; GivenVersion = "1.0"; ExpectedName = "TheComponent"; ExpectedVersion = "1.0" }
            @{ GivenName = "TheComponent"; GivenVersion = "1.1"; ExpectedName = "TheComponent"; ExpectedVersion = "1.1" }
            @{ GivenName = "OtherComponent"; GivenVersion = "1.1"; ExpectedName = "OtherComponent"; ExpectedVersion = "1.1" }
        ) {
            $sut = Get-CdfComponent -Name $GivenName -Version $GivenVersion
            $sut.Name | Should -Be $ExpectedName
            $sut.Version | Should -Be $ExpectedVersion
        }
    }

    Context "no bicep file" {
        BeforeAll {
            New-Item "TestDrive:/Components" -ItemType File -Force | Out-Null
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ComponentsPath = "TestDrive:/Components" } } -ModuleName CloudDeploymentFramework -Verifiable
        }
        
        It "should throw an error" {
            { Get-CdfComponent -Name "TheComponent" -Version "1.0" } | Should -Throw "Failed to find component bicep file 'TestDrive:/Components/TheComponent/v1.0/TheComponent.bicep'"
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Deploy-DfComponent" {
    Context "Parameter set" {
        It "should have parameter '<ExpectedParameter>'" -TestCases @(
            @{ ExpectedParameter = "Name" }
            @{ ExpectedParameter = "Version" }
            @{ ExpectedParameter = "ResourceGroupName" }
         ) {
            Get-Command Deploy-DfComponent  | Should -HaveParameter $ExpectedParameter -Mandatory
        }
    }

    Context "happy path" {
        BeforeAll {
            Mock Get-DfProject { return [PSCustomObject]@{ Name = "Project"; ComponentsPath = "TestDrive:/Components/" } } -ModuleName DeploymentFramework -Verifiable
            New-Item "TestDrive:/Components/Component/v1.0.0/Component.bicep" -Value "dummy" -Force | Out-Null
            Mock New-AzResourceGroupDeployment { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should deploy the component" {
            Deploy-DfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg"
            Should -Invoke New-AzResourceGroupDeployment -Times 1 -ModuleName DeploymentFramework
        }
    }

    Context "no Component.bicep" {
        BeforeAll {
            Mock Get-DfProject { return [PSCustomObject]@{ Name = "Project"; ComponentsPath = "TestDrive:/Components/" } } -ModuleName DeploymentFramework -Verifiable
            Mock Test-Path { return $false } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw an error" {
            { Deploy-DfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg" } | Should -Throw "Failed to find component bicep file 'TestDrive:/Components/Component/v1.0.0/Component.bicep'"
            Should -Invoke Test-Path -Times 1 -ModuleName DeploymentFramework
        }
    }
}
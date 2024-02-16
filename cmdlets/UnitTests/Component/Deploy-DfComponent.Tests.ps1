BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Deploy-DfComponent" {
    BeforeAll {
        Mock New-AzResourceGroupDeployment { throw "should not be called" } -ModuleName DeploymentFramework -Verifiable
        Mock New-AzResourceGroupDeploymentStack { } -ModuleName DeploymentFramework -Verifiable
    }

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
            Mock Get-DfComponent { return [PSCustomObject]@{ Path = "TestDrive:/Components/Component/v1.0.0/Component.bicep" } } -ModuleName DeploymentFramework -Verifiable
        }

        It "should deploy the component" {
            Deploy-DfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg"
            Should -Invoke New-AzResourceGroupDeploymentStack -Times 1 -ModuleName DeploymentFramework
        }
    }

    Context "no Component.bicep" {
        BeforeAll {
            Mock Get-DfComponent { throw "Failed to find component bicep file 'TestDrive:/Components/Component/v1.0.0/Component.bicep'" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw an error" {
            { Deploy-DfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg" } | Should -Throw "Failed to deploy component 'Component' in version '1.0.0': Failed to find component bicep file 'TestDrive:/Components/Component/v1.0.0/Component.bicep'"
        }
    }
}
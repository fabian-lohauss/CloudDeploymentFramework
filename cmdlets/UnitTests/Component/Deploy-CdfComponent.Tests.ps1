BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Deploy-CdfComponent" {
    BeforeAll {
        Mock New-AzResourceGroupDeployment { throw "should not be called" } -ModuleName CloudDeploymentFramework -Verifiable
        Mock New-AzResourceGroupDeploymentStack { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameter set" {
        It "should have parameter '<ExpectedParameter>'" -TestCases @(
            @{ ExpectedParameter = "Name" }
            @{ ExpectedParameter = "Version" }
            @{ ExpectedParameter = "ResourceGroupName" }
         ) {
            Get-Command Deploy-CdfComponent  | Should -HaveParameter $ExpectedParameter -Mandatory
        }
    }

    Context "happy path" {
        BeforeAll {
            Mock Get-CdfComponent { return [PSCustomObject]@{ Path = "TestDrive:/Components/Component/v1.0.0/Component.bicep" } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should deploy the component" {
            Deploy-CdfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg"
            Should -Invoke New-AzResourceGroupDeploymentStack -Times 1 -ModuleName CloudDeploymentFramework
        }
    }

    Context "no Component.bicep" {
        BeforeAll {
            Mock Get-CdfComponent { throw "Failed to find component bicep file 'TestDrive:/Components/Component/v1.0.0/Component.bicep'" } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should throw an error" {
            { Deploy-CdfComponent -Name "Component" -Version "1.0.0" -ResourceGroupName "rg" } | Should -Throw "Failed to deploy component 'Component' in version '1.0.0': Failed to find component bicep file 'TestDrive:/Components/Component/v1.0.0/Component.bicep'"
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Deploy-DfService" {
    BeforeAll {
        Mock New-AzResourceGroupDeployment { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have a '<ExpectedParameter>' parameter" -TestCases @(
            @{ ExpectedParameter = 'Name' }
        ) {
            Get-Command Deploy-DfService | Should -HaveParameter $ExpectedParameter
        }
    }

    Context "happy path" -ForEach @(
        @{ ExpectedDeploymentParameter = ([ScriptBlock]::Create('($ResourceGroupName -eq "aService-rg") -and ($TemplateFile -eq (Get-Item "TestDrive:/keyvault.bicep").FullName)')) }
    ) {
        BeforeAll {
            New-Item "TestDrive:/keyvault.bicep" -ItemType File -Force
            Push-Location "TestDrive:/"
        }

        AfterAll {
            Pop-Location
        }

        It "should deploy the bicep file" {
            Deploy-DfService "aService"
            Should -InvokeVerifiable
            Should -Invoke New-AzResourceGroupDeployment -ParameterFilter $ExpectedDeploymentParameter -ModuleName DeploymentFramework
        }
    }
}
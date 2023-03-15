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
            @{ ExpectedParameter = 'Version' }
        ) {
            Get-Command Deploy-DfService | Should -HaveParameter $ExpectedParameter
        }
    }

    Context "happy path" -ForEach @(
        @{ ExpectedDeploymentParameter = ([ScriptBlock]::Create('($ResourceGroupName -eq "aService-rg") -and ($TemplateFile -eq (Get-Item "TestDrive:/aService/v2.0/stamp.bicep").FullName)')) }
    ) {
        BeforeAll {
            New-Item "TestDrive:/aService/v2.0/stamp.bicep" -ItemType File -Force
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ServicesPath = "TestDrive:/" } } -ModuleName DeploymentFramework
        }

        It "should deploy the bicep file" {
            Deploy-DfService "aService" "2.0"
            Should -InvokeVerifiable
            Should -Invoke New-AzResourceGroupDeployment -ParameterFilter $ExpectedDeploymentParameter -ModuleName DeploymentFramework
        }
    }
}
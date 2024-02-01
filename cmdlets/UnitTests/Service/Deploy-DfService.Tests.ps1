BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psm1 -Force
}

Describe "Deploy-DfService" {
    BeforeAll {
        Mock New-AzDeployment { } -ModuleName DeploymentFramework
        Mock New-AzResourceGroupDeployment { } -ModuleName DeploymentFramework 
    }

    Context "Parameterset" {
        It "should have a '<ExpectedParameter>' parameter" -TestCases @(
            @{ ExpectedParameter = 'Name' }
            @{ ExpectedParameter = 'Version' }
        ) {
            Get-Command Deploy-DfService | Should -HaveParameter $ExpectedParameter
        }
    }

    Context "happy path" {
        BeforeAll {
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ServicesPath = "TestDrive:/Service"; ComponentsPath = "TestDrive:/Component" } } -ModuleName DeploymentFramework
            Mock Import-DfServiceTemplate { return [PSCustomObject]@{ Component = @([PSCustomObject]@{ Name = "aComponent"; Version = "1.0" } )} } -ModuleName DeploymentFramework
            Mock Deploy-DfComponent { } -ModuleName DeploymentFramework
            
            $ExpectedComponentDeploymentParameter = ([ScriptBlock]::Create('($ResourceGroupName -eq "aService-rg") -and ($TemplateFile -eq (Get-Item "TestDrive:/Component/aComponent/v1.0/main.bicep").FullName)'))
            Mock New-AzResourceGroupDeployment { } -ParameterFilter $ExpectedComponentDeploymentParameter -ModuleName DeploymentFramework 
        }

        It "should deploy the bicep file" {
            Deploy-DfService "aService" "2.0"
            Should -Invoke New-AzDeployment -ParameterFilter { ($Location -eq "westeurope") -and ($TemplateFile -eq ("TestDrive:", "Service", "aService", "v2.0", "aService.bicep" -join [System.IO.Path]::DirectorySeparatorChar) ) } -ModuleName DeploymentFramework
        }

        It "should deploy the component" {
            Deploy-DfService "aService" "2.0"
            Should -Invoke Deploy-DfComponent -ParameterFilter { $Name -eq "aComponent" -and $Version -eq "1.0" -and $ResourceGroupName -eq "aService-rg" } -ModuleName DeploymentFramework
        }
        
    }
}
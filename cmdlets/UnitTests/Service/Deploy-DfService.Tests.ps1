BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Deploy-DfService" {
    BeforeAll {
        Mock New-AzDeployment { } -ModuleName DeploymentFramework
        Mock New-AzResourceGroupDeployment { } -ModuleName DeploymentFramework 
        Mock Get-DfProject { return [PSCustomObject]@{ ServicesPath = "TestDrive:/Service"; ComponentsPath = "TestDrive:/Component" } } -ModuleName DeploymentFramework
    }

    Context "Parameterset" {
        It "should have a '<ExpectedParameter.ParameterName>' parameter" -TestCases @(
            @{ ExpectedParameter = @{ HaveParameter = $true; ParameterName = 'Name'; Mandatory = $true } }
            @{ ExpectedParameter = @{ HaveParameter = $true; ParameterName = 'Version'; Mandatory = $true } }
        ) {
            Get-Command Deploy-DfService | Should @ExpectedParameter
        }
    }

    Context "happy path" {
        BeforeAll {
            Mock Import-DfServiceTemplate { return [PSCustomObject]@{ Component = @([PSCustomObject]@{ Name = "aComponent"; Version = "1.0" } ) } } -ModuleName DeploymentFramework
            Mock Deploy-DfComponent { } -ModuleName DeploymentFramework
            Mock Test-DfContext { return $true } -ModuleName DeploymentFramework
            
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

    Context "not logged in to azure" {
        BeforeAll {
            Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ServicesPath = "TestDrive:/Service"; ComponentsPath = "TestDrive:/Component" } } -ModuleName DeploymentFramework
            Mock Import-DfServiceTemplate { return [PSCustomObject]@{ Component = @([PSCustomObject]@{ Name = "aComponent"; Version = "2.0" } ) } } -ModuleName DeploymentFramework
            Mock Test-DfContext { return $false } -ModuleName DeploymentFramework
            Mock New-AzDeployment { throw "should not be called" } -ModuleName DeploymentFramework
            Mock Deploy-DfComponent { throw "should not be called" } -ModuleName DeploymentFramework
        }

        It "should throw an error" {
            { Deploy-DfService "aService" "2.0" } | Should -Throw "You are not logged in to Azure. Run Connect-DfEnvironment to log in."
        }

        It "should not call New-AzDeployment" {
            { Deploy-DfService "aService" "2.0" } 
            Should -Not -Invoke New-AzDeployment -ModuleName DeploymentFramework
        }

        It "should not call Deploy-DfComponent" {
            { Deploy-DfService "aService" "2.0" } 
            Should -Not -Invoke Deploy-DfComponent -ModuleName DeploymentFramework
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Deploy-CdfService" {
    BeforeAll {
        Mock New-AzDeployment { } -ModuleName CloudDeploymentFramework
        Mock New-AzResourceGroupDeployment { } -ModuleName CloudDeploymentFramework 
        Mock Get-CdfProject { return [PSCustomObject]@{ ServicesPath = "TestDrive:/Service"; ComponentsPath = "TestDrive:/Component" } } -ModuleName CloudDeploymentFramework
    }

    Context "Parameterset" {
        It "should have a '<ExpectedParameter.ParameterName>' parameter" -TestCases @(
            @{ ExpectedParameter = @{ HaveParameter = $true; ParameterName = 'Name'; Mandatory = $true } }
            @{ ExpectedParameter = @{ HaveParameter = $true; ParameterName = 'Version'; Mandatory = $true } }
        ) {
            Get-Command Deploy-CdfService | Should @ExpectedParameter
        }
    }

    Context "happy path" {
        BeforeAll {
            Mock Import-CdfServiceTemplate { return [PSCustomObject]@{ Component = @([PSCustomObject]@{ Name = "aComponent"; Version = "1.0" } ) } } -ModuleName CloudDeploymentFramework
            Mock Deploy-CdfComponent { } -ModuleName CloudDeploymentFramework
            Mock Test-CdfContext { return $true } -ModuleName CloudDeploymentFramework
            
            $ExpectedComponentDeploymentParameter = ([ScriptBlock]::Create('($ResourceGroupName -eq "aService-rg") -and ($TemplateFile -eq (Get-Item "TestDrive:/Component/aComponent/v1.0/main.bicep").FullName)'))
            Mock New-AzResourceGroupDeployment { } -ParameterFilter $ExpectedComponentDeploymentParameter -ModuleName CloudDeploymentFramework 
        }

        It "should deploy the service template" {
            Deploy-CdfService "aService" "2.0"
            Should -Invoke New-AzDeployment -ParameterFilter { ($Location -eq "westeurope") -and ($TemplateFile -eq ("TestDrive:", "Service", "aService", "v2.0", "aService.bicep" -join [System.IO.Path]::DirectorySeparatorChar) ) } -ModuleName CloudDeploymentFramework
        }

        It "should deploy the component" {
            Deploy-CdfService "aService" "2.0"
            Should -Invoke Deploy-CdfComponent -ParameterFilter { $Name -eq "aComponent" -and $Version -eq "1.0" -and $ResourceGroupName -eq "aService-rg" } -ModuleName CloudDeploymentFramework
        }
    }

    Context "not logged in to azure" {
        BeforeAll {
            Mock Get-CdfProject { return New-Object -TypeName PSCustomObject -Property @{ ServicesPath = "TestDrive:/Service"; ComponentsPath = "TestDrive:/Component" } } -ModuleName CloudDeploymentFramework
            Mock Import-CdfServiceTemplate { return [PSCustomObject]@{ Component = @([PSCustomObject]@{ Name = "aComponent"; Version = "2.0" } ) } } -ModuleName CloudDeploymentFramework
            Mock Test-CdfContext { return $false } -ModuleName CloudDeploymentFramework
            Mock New-AzDeployment { throw "should not be called" } -ModuleName CloudDeploymentFramework
            Mock Deploy-CdfComponent { throw "should not be called" } -ModuleName CloudDeploymentFramework
        }

        It "should throw an error" {
            { Deploy-CdfService "aService" "2.0" } | Should -Throw "You are not logged in to Azure. Run Connect-CdfEnvironment to log in."
        }

        It "should not call New-AzDeployment" {
            { Deploy-CdfService "aService" "2.0" } 
            Should -Not -Invoke New-AzDeployment -ModuleName CloudDeploymentFramework
        }

        It "should not call Deploy-CdfComponent" {
            { Deploy-CdfService "aService" "2.0" } 
            Should -Not -Invoke Deploy-CdfComponent -ModuleName CloudDeploymentFramework
        }
    }
}
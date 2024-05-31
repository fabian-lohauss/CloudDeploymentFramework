BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Write-CdfLog" {
    BeforeAll {
        Mock Write-Host { } -ModuleName CloudDeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have parameter Message" {
            Get-Command Write-CdfLog | Should -HaveParameter Message -Type String
        }

        It "should have switch StartGroup" {
            Get-Command Write-CdfLog | Should -HaveParameter StartGroup -Type Switch
        }

        It "should have switch EndGroup" {
            Get-Command Write-CdfLog | Should -HaveParameter EndGroup -Type Switch
        }

        It "should throw with StartGroup and EndGroup" {
            { Write-CdfLog -Message "Test" -StartGroup -EndGroup } | Should -Throw
        }
    }

    Context "Outside of pipeline" {
        BeforeAll {
            Mock Test-CdfDeploymentPipeline { return $false } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should write to the console" {
            Write-CdfLog "Test"
            Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Message -eq "Test" } -ModuleName CloudDeploymentFramework 
        }

        It "should not start a group" {
            Write-CdfLog -Message "Test" -StartGroup
            Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Message -eq "Test" } -ModuleName CloudDeploymentFramework 
        }

        It "should not end a group" {
            Write-CdfLog -EndGroup
            Assert-MockCalled Write-Host -Exactly 0 -ModuleName CloudDeploymentFramework 
        }
    }

    Context "In pipeline" {
        BeforeAll {
            Mock Test-CdfDeploymentPipeline { return $true } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should write to the console" {
            Write-CdfLog "Test"
            Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Message -eq "Test" } -ModuleName CloudDeploymentFramework 
        }

        It "should start a group" {
            Write-CdfLog -Message "Test" -StartGroup
            Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Message -eq "##[group]Test" } -ModuleName CloudDeploymentFramework 
        }

        It "should end a group" {
            Write-CdfLog -EndGroup
            Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Message -eq "##[endgroup]" } -ModuleName CloudDeploymentFramework 
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Add-CdfComponent" {
    Context "Parameterset" {
        It "should have a '<ExpectedParameter>' parameter" -TestCases @(
            @{ ExpectedParameter = 'Name' }
            @{ ExpectedParameter = 'Path' }
        ) {
            Get-Command Add-CdfComponent | Should -HaveParameter $ExpectedParameter
        }

        It "should accept 'Path' from the pipeline property" {
            (Get-Command Add-CdfComponent).Parameters["Path"].Attributes.ValueFromPipelineByPropertyName | Should -be $true
        }
    }

    Context "happy path" {
        BeforeEach {
            Mock Import-CdfServiceTemplate { return New-Object -TypeName PSCustomObject -Property @{ Component = [System.Collections.ArrayList]@(@{ Name = "TheComponent"; Version = "1.1" }) } } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Export-CdfServiceTemplate { New-Item "TestDrive:/Services/AService/v1.0/AService.json" -ItemType File -Value ($Object | ConvertTo-Json) -Force | Out-Null } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Get-CdfComponent { return @{ Version = "1.1" } } -ModuleName CloudDeploymentFramework -Verifiable
        }
        
        It "should add the component to the service template configuration file" {
            Add-CdfComponent -Path "TestDrive:/Services/AService/v1.0" -Name "TheComponent"
            Should -InvokeVerifiable
            $Config = (Get-Content "TestDrive:/Services/AService/v1.0/AService.json" | ConvertFrom-Json)
            $Config.Component[0].Name | Should -Be "TheComponent"
            $Config.Component[0].Version | Should -Be "1.1"
        }

    }
}
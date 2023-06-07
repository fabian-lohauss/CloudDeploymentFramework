BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Add-DfComponent" {
    Context "Parameterset" {
        It "should have a '<ExpectedParameter>' parameter" -TestCases @(
            @{ ExpectedParameter = 'Name' }
            @{ ExpectedParameter = 'Path' }
        ) {
            Get-Command Add-DfComponent | Should -HaveParameter $ExpectedParameter
        }

        It "should accept 'Path' from the pipeline property" {
            (Get-Command Add-DfComponent).Parameters["Path"].Attributes.ValueFromPipelineByPropertyName | Should -be $true
        }
    }

    Context "happy path" {
        BeforeEach {
            Mock Import-DfServiceTemplate { return New-Object -TypeName PSCustomObject -Property @{ Component = [System.Collections.ArrayList]@(@{ Name = "TheComponent"; Version = "1.1" }) } } -ModuleName DeploymentFramework -Verifiable
            Mock Export-DfServiceTemplate { New-Item "TestDrive:/Services/AService/v1.0/AService.json" -ItemType File -Value ($Object | ConvertTo-Json) -Force | Out-Null } -ModuleName DeploymentFramework -Verifiable
            Mock Get-DfComponent { return @{ Version = "1.1" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should add the component to the service template configuration file" {
            Add-DfComponent -Path "TestDrive:/Services/AService/v1.0" -Name "TheComponent"
            Should -InvokeVerifiable
            $Config = (Get-Content "TestDrive:/Services/AService/v1.0/AService.json" | ConvertFrom-Json)
            $Config.Component[0].Name | Should -Be "TheComponent"
            $Config.Component[0].Version | Should -Be "1.1"
        }

    }
}
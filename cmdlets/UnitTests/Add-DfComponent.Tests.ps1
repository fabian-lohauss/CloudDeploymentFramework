BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Add-DfComponent" {
    Context "happy path" {
        BeforeEach {
            Mock Import-DfServiceTemplate { return New-Object -TypeName PSCustomObject -Property @{ Component = New-Object -TypeName PSCustomObject } } -ModuleName DeploymentFramework -Verifiable
            Mock Export-DfServiceTemplate { New-Item "TestDrive:/Services/AService/v1.0/AService.json" -ItemType File -Value ($Object | ConvertTo-Json) -Force | Out-Null } -ModuleName DeploymentFramework -Verifiable
            Mock Get-DfComponent { return @{ Version = "1.1" } } -ModuleName DeploymentFramework -Verifiable
        }
        
        It "should add the component to the service template configuration file" {
            Add-DfComponent -Path "TestDrive:/Services/AService/v1.0" -Name "TheComponent"
            Should -InvokeVerifiable
            $Config = (Get-Content "TestDrive:/Services/AService/v1.0/AService.json" | ConvertFrom-Json)
            $Config.Component.TheComponent | Should -Be "1.1"
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Export-DfServiceTemplate" {
    BeforeAll {
        Mock Get-DfProject { return New-Object -TypeName PSCustomObject -Property @{ ServicesPath = "TestDrive:/Services" } } -ModuleName DeploymentFramework -Verifiable
    }

    Context "happy path" {
        It "should create service template folder" {
            $Template = New-Object -TypeName PSCustomObject -Property @{ Name = "aService"; Version = "1.0"; Path = "TestDrive:/Services/aService/v1.0"; Component = @{ "TheComponent" = "1.1"} }
            Export-DfServiceTemplate -Object $Template  

            Should -InvokeVerifiable

            $sut = Get-Content "TestDrive:/Services/aService/v1.0/aService.json" | ConvertFrom-Json
            $sut.Name | Should -Be "aService"
            $sut.Version | Should -Be "1.0"
            $sut.Component.TheComponent | Should -Be "1.1"
        }
    }

    Context "handling path property" {
        It "should remove the path property" {
            $Template = New-Object -TypeName PSCustomObject -Property @{ Name = "aService"; Version = "1.0"; Path = "TestDrive:/Services/aService/v1.0"; Component = @{ "TheComponent" = "1.1"} }
            Export-DfServiceTemplate -Object $Template  

            Should -InvokeVerifiable

            $sut = Get-Content "TestDrive:/Services/aService/v1.0/aService.json" | ConvertFrom-Json
            $sut.Path | Should -Be $null
        }

        It "should not throw on missing path property" {
            $Template = New-Object -TypeName PSCustomObject -Property @{ Name = "aService"; Version = "1.0"; Component = @{ "TheComponent" = "1.1"} }
            Export-DfServiceTemplate -Object $Template  

            Should -InvokeVerifiable

            $sut = Get-Content "TestDrive:/Services/aService/v1.0/aService.json" | ConvertFrom-Json
            $sut.Path | Should -Be $null
        }
    }
}
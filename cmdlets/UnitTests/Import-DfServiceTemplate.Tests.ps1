BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Import-DfServiceTemplate" {
    Context "happy path" {
        BeforeAll {
            New-Item "TestDrive:/Services/SecondService/v2.1/SecondService.json" -ItemType File -Value '{ "Name": "SecondService", "Version": "2.1", "Component": { "OtherComponent": "1.3"} }'-Force
        }

        It "should return the service template" {
            $sut = Import-DfServiceTemplate -Path "TestDrive:/Services/SecondService/v2.1"

            $sut | Should -BeOfType [PSCustomObject]
            $sut.Name | Should -Be "SecondService"
            $sut.Version | Should -Be "2.1"
            $sut.Component.OtherComponent | Should -Be "1.3"
            $sut.Path | Should -Be "TestDrive:/Services/SecondService/v2.1"
        }
    }
}
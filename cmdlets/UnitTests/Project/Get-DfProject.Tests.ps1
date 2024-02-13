BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfProject" {
    Context "return object" {
        BeforeAll {
            Mock Find-DfProjectFolder { return New-Object -Type PSCustomObject -Property @{ FullName = ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar) } } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the base path" -TestCases @(
            @{ PropertyName = "Path"; ExpectedValue = ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ComponentsPath"; ExpectedValue = ("TestDrive:", "Components" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ServicesPath"; ExpectedValue = ("TestDrive:", "Services" -join [System.IO.Path]::DirectorySeparatorChar) }
        ) {
            (Get-DfProject).$PropertyName | Should -Be $ExpectedValue
            Should -InvokeVerifiable
        }
    }
}
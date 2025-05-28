BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfProject" {
    Context "return object" {
        BeforeAll {
            Mock Find-CdfProjectFolder { return New-Object -Type PSCustomObject -Property @{ FullName = ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar) } } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the base path" -TestCases @(
            @{ PropertyName = "Path"; ExpectedValue = ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ComponentsPath"; ExpectedValue = ("TestDrive:", "Components" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ServicesPath"; ExpectedValue = ("TestDrive:", "Services" -join [System.IO.Path]::DirectorySeparatorChar) }
        ) {
            (Get-CdfProject).$PropertyName | Should -Be $ExpectedValue
            Should -InvokeVerifiable
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfProject" {
    BeforeAll {
        Mock -CommandName Find-CdfProjectFolder -ModuleName CloudDeploymentFramework -MockWith {
            return @{ FullName = "TestDrive:/" }
        }

        New-Item -Path "TestDrive:/.cdf" -ItemType Directory -Force | Out-Null
        New-Item -Path "TestDrive:/.cdf/Configuration.json" -ItemType File -Force | Out-Null
        $Configuration = @{
            Name           = "TestProject"
            Path           = "TestDrive:"
            ComponentsPath = "TestDrive:/Components"
            ServicesPath   = "TestDrive:/Services"
        }
        $Configuration | ConvertTo-Json | Out-File "TestDrive:/.cdf/Configuration.json"  -Encoding utf8 -Force | Out-Null
    }

    Context "return type" {
        It "should return a PSCustomObject" {
            (Get-CdfProject).GetType().Name | Should -Be "PSCustomObject"
            Should -InvokeVerifiable
        }
    }

    Context "output properties" {
        BeforeAll {
            Push-Location "TestDrive:/"
        }

        AfterAll {
            Pop-Location
        }

        It "should have property <PropertyName>" -TestCases @(
            @{ PropertyName = "Name"; ExpectedValue = "TestProject" }
            @{ PropertyName = "Path"; ExpectedValue = ("TestDrive:", "" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ComponentsPath"; ExpectedValue = ("TestDrive:", "Components" -join [System.IO.Path]::DirectorySeparatorChar) }
            @{ PropertyName = "ServicesPath"; ExpectedValue = ("TestDrive:", "Services" -join [System.IO.Path]::DirectorySeparatorChar) }
        ) {
            $Value = (Get-CdfProject).$PropertyName
            $Value | Should -Be $ExpectedValue
            Should -InvokeVerifiable
        }
    }
}
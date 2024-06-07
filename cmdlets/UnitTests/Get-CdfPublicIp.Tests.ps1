BeforeAll {
    Import-Module $PSScriptRoot/../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfPublicIp" {
    BeforeAll {
        Mock Invoke-WebRequest { return @{ Content = "1.2.3.4" } } -ModuleName CloudDeploymentFramework
    }

    Context "When invoked" {
        It "should call Invoke-WebRequest with the correct URI" {
            Get-CdfPublicIp
            Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -eq "http://ipinfo.io/ip" -and $UseBasicParsing -eq $true } -ModuleName CloudDeploymentFramework 
        }

        It "Should return the content of the Invoke-WebRequest call" {
            $result = Get-CdfPublicIp
            $result | Should -Be "1.2.3.4"
        }
    }
}
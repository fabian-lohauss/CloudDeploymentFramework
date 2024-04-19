BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfAdoPipExtraIndexUrl" {
    Context "token in keyvault" {
        BeforeAll {
            Mock Get-AzKeyVaultSecret -ParameterFilter { $Name -eq "PatDisplayName" } { 
                Function Get-MockSecret {
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='Used for mocking in tests only')]
                    param()
                    return [PSCustomObject]@{ SecretValue = ("my-token" | ConvertTo-SecureString -AsPlainText -Force) }
                }
                return Get-MockSecret
            } -ModuleName CloudDeploymentFramework
        }

        It "Should return the correct URL" {
            $PipPATParameters = @{
                OrganizationName = "my-organization"
                PatDisplayName   = "PatDisplayName"
                KeyvaultName     = "kv-test"
            }
            $ProjectName = "my-project"
            $FeedName = "my-feed"
            $url = Get-CdfAdoPipExtraIndexUrl @PipPATParameters -ProjectName $ProjectName -FeedName $FeedName
            $url | Should -Be "https://my-organization:my-token@pkgs.dev.azure.com/my-organization/my-project/_packaging/my-feed/pypi/simple/"
        }
    }

}
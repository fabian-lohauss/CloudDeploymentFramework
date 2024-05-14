BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfAdoPipExtraIndexUrl" {
    Context "token in keyvault" {
        BeforeAll {
            Mock Get-CdfSecret -ParameterFilter { $Name -eq "PatDisplayName" } { 
                Function Get-MockSecret {
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Used for mocking in tests only')]
                    param()
                    return [PSCustomObject]@{ SecretValue = ("my-token" | ConvertTo-SecureString -AsPlainText) }
                }
                return Get-MockSecret
            } -ModuleName CloudDeploymentFramework
        }

        It "Should return the correct URL" {
            $PipPATParameters = @{
                OrganizationName = "my-organization"
                SecretName       = "PatDisplayName"
                VaultName        = "kv-test"
            }
            $ProjectName = "my-project"
            $FeedName = "my-feed"
            $url = Get-CdfAdoPipExtraIndexUrl @PipPATParameters -ProjectName $ProjectName -FeedName $FeedName
            $url | Should -Be "https://my-organization:my-token@pkgs.dev.azure.com/my-organization/my-project/_packaging/my-feed/pypi/simple/"
        }
    }

    Context "parameter set" {
        It "should have mandatory parameter OrganizationName" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory parameter ProjectName" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "ProjectName" -Mandatory
        }

        It "should have mandatory parameter SecretName" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "SecretName" -Mandatory
        }

        It "should have mandatory parameter VaultName" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "VaultName" -Mandatory
        }

        It "should have mandatory parameter FeedName" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "FeedName" -Mandatory
        }

        It "should have optional parameter AllowKeyVaultNetworkRuleUpdate" {
            Get-Command Get-CdfAdoPipExtraIndexUrl | Should -HaveParameter "AllowKeyVaultNetworkRuleUpdate"
        }
    }

    Context "parameter AllowKeyVaultNetworkRuleUpdate" {
        It "should be passed to Get-CdfSecret" {
            Mock Get-CdfSecret { return [PSCustomObject]@{ SecretValue = "my-secret" | ConvertTo-SecureString -AsPlainText } } -ModuleName CloudDeploymentFramework

            $Parameters = @{
                SecretName                     = "PatDisplayName"
                VaultName                      = "kv-test"
                AllowKeyVaultNetworkRuleUpdate = $true
                OrganizationName               = "my-organization"
                ProjectName                    = "my-project"
                FeedName                       = "my-feed"
            }
            Get-CdfAdoPipExtraIndexUrl @Parameters 
            Assert-MockCalled Get-CdfSecret -Exactly 1 -Scope It -ParameterFilter { $AllowKeyVaultNetworkRuleUpdate -eq $true } -ModuleName CloudDeploymentFramework
        }
    }
}
BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Set-CdfSecret" {
    BeforeAll {
        Mock Set-AzKeyVaultSecret { throw "should be mocked" } -ModuleName CloudDeploymentFramework
        Mock Add-AzKeyVaultNetworkRule { } -ModuleName CloudDeploymentFramework
    }

    Context "secret can be set" {
        BeforeAll {
            Mock Set-AzKeyVaultSecret { return [PSCustomObject]@{ SecretValue = ("the secret" | ConvertTo-SecureString -AsPlainText -Force) } } -ModuleName CloudDeploymentFramework
        }

        It "should return the secret" {
            $secret = Set-CdfSecret -VaultName "myvault" -Name "mysecret" -SecretValue ("the secret" | ConvertTo-SecureString -AsPlainText) -PassThru
            $secret.SecretValue | ConvertFrom-SecureString -AsPlainText | Should -Be "the secret"
        }
    }

    Context "Keyvault with firewall and AllowKeyVaultNetworkRuleUpdate" {
        BeforeAll {
            $Script:SetAzKeyVaultSecretCallCount = 0
            Mock Set-AzKeyVaultSecret { 
                $Script:SetAzKeyVaultSecretCallCount++
                if ($Script:SetAzKeyVaultSecretCallCount -eq 1) {
                    throw @"
Operation returned an invalid status code 'Forbidden'
Code: Forbidden
Message: Client address is not authorized and caller is not a trusted service.
Client address: 111.22.3.44
Caller: appid=52d63b7b-747d-4529-8d4a-bb70e90dd610;oid=8b0c99f9-aaf3-4a9c-9aaf-34827afe25a5;iss=https://sts.windows.net/d4b4082e-2f58-4987-b000-46525a32e93c/
Vault: kv-test;location=westeurope
"@
                }
                return [PSCustomObject]@{ Secret = ("the secret" | ConvertTo-SecureString -AsPlainText) }
            } -ModuleName CloudDeploymentFramework

            Mock Add-AzKeyVaultNetworkRule {  } -ModuleName CloudDeploymentFramework
        }

        It "should call Add-AzKeyVaultNetworkRule with IpAddressRange '111.22.3.44' and retry" {
            Set-CdfSecret -VaultName "myvault" -Name "mysecret" -SecretValue ("the secret" | ConvertTo-SecureString -AsPlainText) -AllowKeyVaultNetworkRuleUpdate
            Assert-MockCalled Add-AzKeyVaultNetworkRule -Exactly 1 -ParameterFilter { $IpAddressRange -eq "111.22.3.44" } -ModuleName CloudDeploymentFramework
            Assert-MockCalled Set-AzKeyVaultSecret -Exactly 2 -ModuleName CloudDeploymentFramework
        }
    }
}
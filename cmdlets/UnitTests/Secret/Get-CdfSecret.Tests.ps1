BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfSecret" {
    BeforeAll {
        Mock Get-AzKeyVaultSecret { throw "should be mocked" } -ModuleName CloudDeploymentFramework
        Mock Add-AzKeyVaultNetworkRule { } -ModuleName CloudDeploymentFramework
    }

    Context "Parameter set" {
        It "should have parameter '[<Type>]$<Name>'" -ForEach @(
            @{ Name = "VaultName"; Type = "String"; Mandatory = $true}
            @{ Name = "Name"; Type = "String"; Mandatory = $true}
            @{ Name = "AllowKeyVaultNetworkRuleUpdate"; Type = "Switch"; Mandatory = $false}
            @{ Name = "AsPlainText"; Type = "Switch"; Mandatory = $false}
        ) {
            Get-Command Get-CdfSecret | Should -HaveParameter $PSItem.Name -Type $PSItem.Type -Mandatory:$PSItem.Mandatory
        }
    }

    Context "secret exists" {
        BeforeAll {
            Mock Get-AzKeyVaultSecret { return [PSCustomObject]@{ SecretValue = ("the secret" | ConvertTo-SecureString -AsPlainText -Force) } } -ModuleName CloudDeploymentFramework
        }

        It "should return the secret" {
            $secret = Get-CdfSecret -VaultName "myvault" -Name "mysecret"
            $secret.SecretValue | ConvertFrom-SecureString -AsPlainText | Should -Be "the secret"
        }
    }

    Context "Keyvault with firewall and AllowKeyVaultNetworkRuleUpdate" {
        BeforeAll {
            $Script:GetAzKeyVaultSecretCallCount = 0
            Mock Get-AzKeyVaultSecret { 
                $Script:GetAzKeyVaultSecretCallCount++
                if ($Script:GetAzKeyVaultSecretCallCount -eq 1) {
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
            Get-CdfSecret -VaultName "myvault" -Name "mysecret" -AllowKeyVaultNetworkRuleUpdate
            Assert-MockCalled Add-AzKeyVaultNetworkRule -Exactly 1 -ParameterFilter { $IpAddressRange -eq "111.22.3.44" } -ModuleName CloudDeploymentFramework
            Assert-MockCalled Get-AzKeyVaultSecret -Exactly 2 -ModuleName CloudDeploymentFramework
        }
    }

    Context "Keyvault with firewall and no AllowKeyVaultNetworkRuleUpdate" {
        BeforeAll {
            Mock Get-AzKeyVaultSecret { 
                throw @"
Operation returned an invalid status code 'Forbidden'
Code: Forbidden
Message: Client address is not authorized and caller is not a trusted service.
Client address: 1.2.3.4
Caller: appid=52d63b7b-747d-4529-8d4a-bb70e90dd610;oid=8b0c99f9-aaf3-4a9c-9aaf-34827afe25a5;iss=https://sts.windows.net/d4b4082e-2f58-4987-b000-46525a32e93c/
Vault: kv-test;location=westeurope
"@
            } -ModuleName CloudDeploymentFramework
        }

        It "should rethrow the exception" {
            { Get-CdfSecret -VaultName "myvault" -Name "mysecret" } | Should -Throw -ExpectedMessage @"
Operation returned an invalid status code 'Forbidden'
Code: Forbidden
Message: Client address is not authorized and caller is not a trusted service.
Client address: 1.2.3.4
Caller: appid=52d63b7b-747d-4529-8d4a-bb70e90dd610;oid=8b0c99f9-aaf3-4a9c-9aaf-34827afe25a5;iss=https://sts.windows.net/d4b4082e-2f58-4987-b000-46525a32e93c/
Vault: kv-test;location=westeurope
"@
        }
    }

    Context "Keyvault with firewall and no IP address in exception message" {
        BeforeAll {
            Mock Get-AzKeyVaultSecret { 
                throw "other Exception message"
            } -ModuleName CloudDeploymentFramework
        }

        It "should rethrow the exception" {
            { Get-CdfSecret -VaultName "myvault" -Name "mysecret" } | Should -Throw -ExpectedMessage "other Exception message"
        }
    }

    Context "Parameter AsPlainText" {
        It "should be passed to Get-AzKeyVaultSecret" {
            Mock Get-AzKeyVaultSecret { } -ModuleName CloudDeploymentFramework
            Get-CdfSecret -VaultName "myvault" -Name "mysecret" -AsPlainText
            Assert-MockCalled Get-AzKeyVaultSecret -Exactly 1 -ParameterFilter { $AsPlainText -eq $true } -ModuleName CloudDeploymentFramework
        }
    }
 
}
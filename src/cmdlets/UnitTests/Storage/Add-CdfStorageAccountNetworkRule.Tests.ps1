BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Add-CdfStorageAccountNetworkRule" {
    BeforeAll {
        Mock Update-AzStorageAccountNetworkRuleSet { } -ModuleName CloudDeploymentFramework 
        Mock Get-AzStorageAccountNetworkRuleSet { } -ModuleName CloudDeploymentFramework
    }

    Context "parameter set" {
        It "should have correct parameter set" {
            Get-Command Add-CdfStorageAccountNetworkRule | Should -HaveParameter ResourceGroupName -Mandatory
            Get-Command Add-CdfStorageAccountNetworkRule | Should -HaveParameter StorageAccountName -Mandatory
            Get-Command Add-CdfStorageAccountNetworkRule | Should -HaveParameter IpAddress -Mandatory
        }
    }

    Context "empty ip rule set" {
        BeforeAll {
            Mock Get-AzStorageAccountNetworkRuleSet { return @{ IPRules = @() } } -ModuleName CloudDeploymentFramework
        }

        It "should add IP to rule set" {
            $resourceGroupName = "testresourcegroup"
            $storageAccountName = "teststorageaccount"
            $ipAddress = "1.2.3.4"
            Add-CdfStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -IpAddress $ipAddress
            Assert-MockCalled Update-AzStorageAccountNetworkRuleSet -ParameterFilter { $ResourceGroupName -eq "testresourcegroup" -and $Name -eq "teststorageaccount" -and $IPRule.IPAddressOrRange -eq "1.2.3.4" } -ModuleName CloudDeploymentFramework
        }
    }

    Context "existing ip rule set" {
        BeforeAll {
            Mock Get-AzStorageAccountNetworkRuleSet { return @{ IPRules = @(@{Action = "Allow"; IPAddressOrRange = "2.3.4.5" }) } } -ModuleName CloudDeploymentFramework
        }

        It "should add IP to rule set" {
            $resourceGroupName = "testresourcegroup"
            $storageAccountName = "teststorageaccount"
            $ipAddress = "1.2.3.4"
            Add-CdfStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -IpAddress $ipAddress
            Assert-MockCalled Update-AzStorageAccountNetworkRuleSet -ParameterFilter { $ResourceGroupName -eq "testresourcegroup" -and $Name -eq "teststorageaccount" -and $IPRule.IPAddressOrRange -eq "1.2.3.4" -and $IPRule.IPAddressOrRange -eq "2.3.4.5" } -ModuleName CloudDeploymentFramework
        }
    }

    Context "existing ip rule set with same ip" {
        BeforeAll {
            Mock Get-AzStorageAccountNetworkRuleSet { return [PSCustomObject]@{ IPRules = @([PSCustomObject]@{Action = "Allow"; IPAddressOrRange = "1.2.3.4" }) } } -ModuleName CloudDeploymentFramework
        }

        It "should not add IP to rule set" {
            $resourceGroupName = "testresourcegroup"
            $storageAccountName = "teststorageaccount"
            $ipAddress = "1.2.3.4"
            Add-CdfStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -IpAddress $ipAddress
            Assert-MockCalled Update-AzStorageAccountNetworkRuleSet -Times 0 -ModuleName CloudDeploymentFramework
        }
    }
}
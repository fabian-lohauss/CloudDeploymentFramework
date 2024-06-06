BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfStorageAccount" {
    BeforeAll {
        Mock Get-AzStorageAccount { } -ModuleName CloudDeploymentFramework 
    }

    Context "passing parameters to Get-AzStorageAccount" {
        It "should return the storage account" {
            $storageAccountName = "teststorageaccount"
            $resourceGroupName = "testresourcegroup"
            Get-CdfStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName | Out-Null
            Assert-MockCalled Get-AzStorageAccount -ParameterFilter { $ResourceGroupName -eq "testresourcegroup" -and $Name -eq "teststorageaccount" } -ModuleName CloudDeploymentFramework 
        }
    }
}
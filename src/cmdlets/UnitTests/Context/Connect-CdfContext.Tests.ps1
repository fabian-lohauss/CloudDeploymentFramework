BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Connect-CdfContext" {
    Context "valid project folder" {
        BeforeAll {
            Mock Get-CdfProject { return @{ Environment = @{ SubscriptionId = "TheSubscription" }} } -ModuleName CloudDeploymentFramework -Verifiable
            Mock Connect-AzAccount {} -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should call Connect-AzAccount" {
            Connect-CdfContext
            Should -InvokeVerifiable 
            Should -Invoke Connect-AzAccount -ParameterFilter { $Subscription -eq "TheSubscription" } -ModuleName CloudDeploymentFramework
        }
    }
}
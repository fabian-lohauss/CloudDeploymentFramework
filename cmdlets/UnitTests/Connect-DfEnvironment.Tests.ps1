BeforeAll {
    Import-Module $PSScriptRoot/../src/DeploymentFramework.psm1 -Force
}

Describe "Connect-DfContext" {
    Context "valid project folder" {
        BeforeAll {
            Mock Get-DfProject { return @{ Environment = @{ SubscriptionId = "TheSubscription" }} } -ModuleName DeploymentFramework -Verifiable
            Mock Connect-AzAccount {} -ModuleName DeploymentFramework -Verifiable
        }

        It "should call Connect-AzAccount" {
            Connect-DfContext
            Should -InvokeVerifiable 
            Should -Invoke Connect-AzAccount -ParameterFilter { $Subscription -eq "TheSubscription" } -ModuleName DeploymentFramework
        }
    }
}
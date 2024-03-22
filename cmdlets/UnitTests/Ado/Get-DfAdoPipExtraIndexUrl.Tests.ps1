BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfAdoPipExtraIndexUrl" {
    Context "token in keyvault" {
        BeforeAll {
            Mock Get-AzKeyVaultSecret -ParameterFilter { $Name -eq "PatDisplayName" } { return [PSCustomObject]@{ SecretValue = ("my-token" | ConvertTo-SecureString -AsPlainText -Force) } } -ModuleName DeploymentFramework
        }

        It "Should return the correct URL" {
            $PipPATParameters = @{
                OrganizationName = "my-organization"
                PatDisplayName   = "PatDisplayName"
                KeyvaultName     = "kv-test"
            }
            $ProjectName = "my-project"
            $FeedName = "my-feed"
            $url = Get-DfAdoPipExtraIndexUrl @PipPATParameters -ProjectName $ProjectName -FeedName $FeedName
            $url | Should -Be "https://my-organization:my-token@pkgs.dev.azure.com/my-organization/my-project/_packaging/my-feed/pypi/simple/"
        }
    }

}
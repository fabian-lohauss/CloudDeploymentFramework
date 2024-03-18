BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfGitConfig" {
    Context "user name from git config" {
        BeforeAll {
            Mock git { return @"
user.name=John Doe
"@ } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the username" {
            $config = Get-DfGitConfig
            $config.UserName | Should -Be "John Doe"
            $Config.UserName | Should -BeOfType [string]
        }
    }

    Context "user email from git config" {
        BeforeAll {
            Mock git { return @"    
            user.email=john.doe@contoso.com
"@ } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the user email" {
            $config = Get-DfGitConfig
            $config.UserEmail | Should -Be "john.doe@contoso.com"
            $Config.UserEmail | Should -BeOfType [string]
        }
    }



    Context "OrganizationName from github repository" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://github.com/orgingithub/DeploymentFramework.git
"@ } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-DfGitConfig
            $config.OrganizationName | Should -Be "orgingithub"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }

    Context "OrganizationName from azure devops repository" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://dev.azure.com/orginado/DeploymentFramework/_git/DeploymentFramework
"@ } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-DfGitConfig
            $config.OrganizationName | Should -Be "orginado"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }

    Context "OrganizationName from azure devops repository with usehttppath" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://orginadohttppath@dev.azure.com/orginadohttppath/project/_git/project
"@ } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-DfGitConfig
            $config.OrganizationName | Should -Be "orginadohttppath"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }
}
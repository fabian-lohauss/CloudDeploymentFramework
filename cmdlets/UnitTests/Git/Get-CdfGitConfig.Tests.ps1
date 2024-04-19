BeforeAll {
    Import-Module $PSScriptRoot/../../src/CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Get-CdfGitConfig" {
    Context "user name from git config" {
        BeforeAll {
            Mock git { return @"
user.name=John Doe
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the username" {
            $config = Get-CdfGitConfig
            $config.UserName | Should -Be "John Doe"
            $Config.UserName | Should -BeOfType [string]
        }
    }

    Context "user email from git config" {
        BeforeAll {
            Mock git { return @"    
            user.email=john.doe@contoso.com
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the user email" {
            $config = Get-CdfGitConfig
            $config.UserEmail | Should -Be "john.doe@contoso.com"
            $Config.UserEmail | Should -BeOfType [string]
        }
    }



    Context "OrganizationName from github repository" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://github.com/orgingithub/CloudDeploymentFramework.git
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-CdfGitConfig
            $config.OrganizationName | Should -Be "orgingithub"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }

    Context "OrganizationName from azure devops repository" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://dev.azure.com/orginado/CloudDeploymentFramework/_git/CloudDeploymentFramework
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-CdfGitConfig
            $config.OrganizationName | Should -Be "orginado"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }

    Context "OrganizationName from azure devops repository with usehttppath" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://orginadohttppath@dev.azure.com/orginadohttppath/project/_git/project
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-CdfGitConfig
            $config.OrganizationName | Should -Be "orginadohttppath"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }

    Context "OrganizationName from azure devops repository with usehttppath 2" {
        BeforeAll {
            Mock git { return @"
remote.origin.url=https://org-with-dash-and-httppath@dev.azure.com/org-with-dash-and-httppath/project/_git/project
"@ } -ModuleName CloudDeploymentFramework -Verifiable
        }

        It "should return the git organization name" {
            $config = Get-CdfGitConfig
            $config.OrganizationName | Should -Be "org-with-dash-and-httppath"
            $config.OrganizationName | Should -BeOfType [string]
        }
    }    
}
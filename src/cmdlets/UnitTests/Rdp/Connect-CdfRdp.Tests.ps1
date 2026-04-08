BeforeAll {
    Import-Module $PSScriptRoot/../../CloudDeploymentFramework/CloudDeploymentFramework.psd1 -Force
}

Describe "Connect-CdfRdp source" {
    It "should not contain hardcoded GUIDs or e-mail addresses" {
        $ScriptPath = "$PSScriptRoot/../../CloudDeploymentFramework/Public/Rdp/Connect-CdfRdp.ps1"
        $Content = Get-Content -Path $ScriptPath -Raw

        # GUIDs of the form xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        $Content | Should -Not -Match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

        # E-mail addresses
        $Content | Should -Not -Match '[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'
    }
}

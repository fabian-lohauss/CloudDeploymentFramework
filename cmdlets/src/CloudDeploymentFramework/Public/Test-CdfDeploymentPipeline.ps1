Function Test-CdfDeploymentPipeline {
    if (Test-Path env:/TF_BUILD) {
        $InAdoPipeline = (Get-Item env:/TF_BUILD).Value -eq "True"
    }

    if (Test-Path env:/GITHUB_ACTIONS)  {
        $InGitHubActions = (Get-Item env:/GITHUB_ACTIONS).Value -eq "True"
    }

    $InPipeline = $InAdoPipeline -or $InGitHubActions

    return $InPipeline
}
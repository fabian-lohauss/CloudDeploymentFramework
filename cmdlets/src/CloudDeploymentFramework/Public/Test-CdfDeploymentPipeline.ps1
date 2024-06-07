Function Test-CdfDeploymentPipeline {
    <#
    .SYNOPSIS
    Determines if the script is running in a deployment pipeline.

    .DESCRIPTION
    Determines if the script is running in a deployment pipeline. This function checks for the presence of the environment variables
    TF_BUILD or GITHUB_ACTIONS. If either of these variables are present and set to "True", the function will return $true.

    .EXAMPLE
    Test-CdfDeploymentPipeline
    #>
    
    if (Test-Path env:/TF_BUILD) {
        $InAdoPipeline = (Get-Item env:/TF_BUILD).Value -eq "True"
    }

    if (Test-Path env:/GITHUB_ACTIONS)  {
        $InGitHubActions = (Get-Item env:/GITHUB_ACTIONS).Value -eq "True"
    }

    $InPipeline = $InAdoPipeline -or $InGitHubActions

    return $InPipeline
}
Function Find-DfProjectFolder {
    [CmdletBinding()]
    param ( )

    $CurrentFolder = $pwd
    $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 

    while (-not $ProjectFolderFound) {
        $CurrentFolder = Split-Path $CurrentFolder -Parent
        if ([string]::IsNullOrEmpty($CurrentFolder)) {
            throw ("Failed to find DeploymentFramework project folder in '{0}'" -f $pwd)
        }
        $ProjectFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 
    }

    return (Resolve-Path $CurrentFolder).Path
}

Function Initialize-DfProject {
    [CmdletBinding()]
    param ( )

    $ProjectFolder = Join-Path $PWD -ChildPath ".df"
    if (-not (Test-Path $ProjectFolder)) {
        New-Item -Path $ProjectFolder -ItemType Directory | Out-Null
    }

    $ConfigurationFile = Join-Path $ProjectFolder -ChildPath "Configuration.json"
    if (-not (Test-Path $ConfigurationFile)) {
        New-Item $ConfigurationFile -ItemType File -Value "{}" | Out-Null
    }
}

Function Get-DfProject {
    [CmdletBinding()]
    param ( )

    $Folder = Find-DfProjectFolder
    return @{ Folder = $Folder; Library = Join-Path $Folder -ChildPath "Components" }
}

Function Connect-DfContext {
    [CmdletBinding()]
    param ( )

    Connect-AzAccount -Subscription (Get-DfProject).Environment.SubscriptionId
}

function Get-DfStampTemplate {
    [CmdletBinding()]
    param ( )
    
    $StampFolder = (Get-DfProject).StampFolder
    $Templates = $null
    if (Test-Path $StampFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $StampFolder -Directory)) {
            @{ Name = $Folder.Name } 
        }
    }
    return $Templates
}


function Deploy-DfStamp {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name
    )

    New-AzDeployment -Location "weu" -TemplateFile "ResourceGroup.bicep"
}



function New-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $Project = Get-DfProject
    $ComponentFolder = Join-Path $Project.Library -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item -Path $ComponentFolder -ItemType Directory | Out-Null
    $Properties = @{ 
        Path       = $ComponentFolder;
        Name       = $Name;
        Version    = "1.0-PreRelease"
        PreRelease = $true
    }
    return New-Object -TypeName PSCustomObject -Property $Properties
        
}

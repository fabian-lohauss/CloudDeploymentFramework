Function Find-DfProjectFolder {
    [CmdletBinding()]
    [OutputType("System.IO.DirectoryInfo")]
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
    return Get-Item $CurrentFolder
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
    $Properties = @{ 
        Path           = $Folder.FullName;
        ComponentsPath = Join-Path $Folder.FullName -ChildPath "Components"
        ServicesPath   = Join-Path $Folder.FullName -ChildPath "Services"
    }
    return $Properties
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
    $ComponentFolder = Join-Path $Project.ComponentsPath -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item -Path $ComponentFolder -ItemType Directory | Out-Null
    $Properties = @{ 
        Path       = $ComponentFolder;
        Name       = $Name;
        Version    = "1.0-PreRelease"
        PreRelease = $true
    }
    return New-Object -TypeName PSCustomObject -Property $Properties
        
}


function Add-DfEnvironment {
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$Subscription
    )
    
    $ConfigurationFile = Join-Path (Get-DfProject).Path -ChildPath ".df/Configuration.json"
    $Config = Get-Content $ConfigurationFile | ConvertFrom-Json -AsHashtable
    $Config.Environment = @{ $Name = @{ Subscription = $Subscription } }
    $Config | ConvertTo-Json | Out-File $ConfigurationFile
}

function New-DfServiceTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ServiceTemplateFolder = Join-Path (Get-DfProject).ServicesPath -ChildPath $Name -AdditionalChildPath "v1.0"
    New-Item $ServiceTemplateFolder -ItemType Directory | Out-Null

    $Properties = @{ 
        Name       = $Name; 
        Version    = "1.0-PreRelease";
        PreRelease = $true 
        Path       = $ServiceTemplateFolder
        Component  = @{}
    }
    $ServiceTemplate = New-Object -TypeName PSCustomObject -Property $Properties

    $ServiceTemplate | Export-DfServiceTemplate

    New-Item $ServiceTemplateFolder -Name ("{0}.bicep" -f $Name) -ItemType File | Out-Null

    return $ServiceTemplate
}

function Get-DfServiceTemplate {
    [CmdletBinding()]
    param ( 
        [string]$Name
    )
    
    $ServicesFolder = (Get-DfProject).ServicesPath
    $Templates = $null
    if (Test-Path $ServicesFolder) {
        $Templates = foreach ($Folder in (Get-ChildItem $ServicesFolder -Directory)) {
            if (($Name -eq $Folder.Name) -or ([string]::IsNullOrEmpty($Name))) {
                foreach ($VersionFolder in (Get-ChildItem $Folder -Filter "v*" -Directory)) {
                    Import-DfServiceTemplate -Path $VersionFolder.FullName
                }
            }
        }
    }
    return $Templates
}


function Import-DfServiceTemplate {
    [CmdletBinding()]
    param (
        [string]$Path
    )

    $ServiceTemplateFile = Get-ChildItem $Path -Filter "*.json"
    $ServiceTemplate = Get-Content $ServiceTemplateFile | ConvertFrom-Json
    $ServiceTemplate | Add-Member -NotePropertyName Path -NotePropertyValue $Path
    return $ServiceTemplate
}

function Export-DfServiceTemplate {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject]$Object
    )

    $ServiceTemplateFolder = Join-Path (Get-DfProject).ServicesPath -ChildPath $Object.Name -AdditionalChildPath ("v" + ($Object.Version -replace "-PreRelease", ""))
    $ExportObject = New-Object -TypeName PSCustomObject
    foreach ($Property in ($Object | Get-Member -MemberType NoteProperty)) {
        if ($Property.Name -ne "Path") {
            $PropertyName = $Property.Name
            $ExportObject | Add-Member -NotePropertyName $PropertyName -NotePropertyValue $Object.$PropertyName
        }
    }

    New-Item $ServiceTemplateFolder -Name ("{0}.json" -f $Object.Name) -ItemType File -Value ($ExportObject | ConvertTo-Json) -Force | Out-Null
}

function Get-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name
    )

    $Project = Get-DfProject
    $Components = foreach ($ComponentFolder in (Get-ChildItem $Project.ComponentsPath)) {
        if (($ComponentFolder.BaseName -like $Name) -or [string]::IsNullOrEmpty($Name)) {
            foreach ($VersionFolder in (Get-ChildItem $ComponentFolder -Filter "v*")) {
                New-Object -TypeName PSCustomObject -Property @{ Name = $ComponentFolder.BaseName; Version = ($VersionFolder.BaseName -replace "v", "") }
            }        
        }
    }
    return $Components
}

function Add-DfComponent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Position = 0)]
        [string]$Name
    )

    $Component = Get-DfComponent $Name
    $ServiceTemplate = Import-DfServiceTemplate -Path $Path
    $ServiceTemplate.Component | Add-Member -NotePropertyName $Name -NotePropertyValue $Component.Version 
    Export-DfServiceTemplate -Object $ServiceTemplate
}

function Deploy-DfService {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$Name,

        [Parameter(Position=1)]
        [string]$Version
    )

    $ProjectConfiguration = Get-DfProject 
    $ProjectFolder = Join-Path $ProjectConfiguration.ServicesPath -ChildPath $Name -AdditionalChildPath ("v{0}" -f $Version)
    $Template = Get-ChildItem $ProjectFolder -Filter "*.bicep" 
    New-AzResourceGroupDeployment -ResourceGroupName "$Name-rg" -TemplateFile $Template.FullName
}
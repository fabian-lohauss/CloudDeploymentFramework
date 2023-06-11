Function Find-DfProjectFolder {
    [CmdletBinding()]
    [OutputType("System.IO.DirectoryInfo")]
    param ( )

    $CurrentFolder = $pwd
    $ServiceFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 

    while (-not $ServiceFolderFound) {
        $CurrentFolder = Split-Path $CurrentFolder -Parent
        if ([string]::IsNullOrEmpty($CurrentFolder)) {
            throw ("Failed to find DeploymentFramework project folder in '{0}'" -f $pwd)
        }
        $ServiceFolderFound = Join-Path $CurrentFolder -ChildPath ".df" | Test-Path 
    }
    return Get-Item $CurrentFolder
}

Function Initialize-DfProject {
    [CmdletBinding()]
    param (
        [Parameter( ParameterSetName = "Default", Mandatory)]
        [string]$Name
    )

    $ServiceFolder = Join-Path $PWD -ChildPath ".df"
    if (-not (Test-Path $ServiceFolder)) {
        New-Item -Path $ServiceFolder -ItemType Directory | Out-Null
    }

    $ConfigurationFile = Join-Path $ServiceFolder -ChildPath "Configuration.json"
    if (-not (Test-Path $ConfigurationFile)) {
        $Content = @{ Name = $Name } | ConvertTo-Json
        New-Item $ConfigurationFile -ItemType File -Value $Content | Out-Null
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
        Component  = (New-Object -TypeName System.Collections.ArrayList)
    }
    $ServiceTemplate = New-Object -TypeName PSCustomObject -Property $Properties

    $ServiceTemplate | Export-DfServiceTemplate

    New-Item $ServiceTemplateFolder -Name ("{0}.bicep" -f $Name) -ItemType File -value @"
    targetScope = 'subscription'
    
    param name string
    param location string = deployment().location
    
    resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = { name: name, location: location }
"@ | Out-Null

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
    Write-Verbose ("Adding component {0} to service template {1}" -f $Name, $Path)
    $Component = Get-DfComponent $Name
    $ServiceTemplate = Import-DfServiceTemplate -Path $Path
    $ServiceTemplate.Component += @([PSCustomObject]@{ Name = $Component.Name; Version = $Component.Version })
    Export-DfServiceTemplate -Object $ServiceTemplate
}

Function Deploy-DfComponent {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName
    )

    Write-Verbose ("Deploying component {0} v{1} to resource group {2}" -f $Name, $Version, $ResourceGroupName)
    $ProjectConfiguration = Get-DfProject 
    $ComponentFolder = Join-Path $ProjectConfiguration.ComponentsPath -ChildPath $Name -AdditionalChildPath ("v{0}" -f $Version)
    $ComponentTemplate = Get-ChildItem $ComponentFolder -Filter "main.bicep"
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $ComponentTemplate.FullName | Out-Null
    Write-Verbose ("Component {0} v{1} deployed to resource group {2}" -f $Name, $Version, $ResourceGroupName)
}

function Deploy-DfService {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name,

        [Parameter(Position = 1)]
        [string]$Version
    )

    Write-Verbose ("Deploying service {0} v{1}" -f $Name, $Version)

    $ProjectConfiguration = Get-DfProject 
    $ServiceFolder = Join-Path $ProjectConfiguration.ServicesPath -ChildPath $Name -AdditionalChildPath ("v{0}" -f $Version)

    $Self = Import-DfServiceTemplate -Path $ServiceFolder

    $ServiceTemplate = Join-Path $ServiceFolder -ChildPath "$Name.bicep" 
    New-AzDeployment -TemplateFile $ServiceTemplate -Location "westeurope" -TemplateParameterObject @{ Name = ("{0}-rg" -f $Name) } | Out-Null

    $Components = $Self | Select-Object -ExpandProperty Component
    foreach ($Component in $Components) {
        Deploy-DfComponent -Name $Component.Name -Version $Component.Version -ResourceGroupName ("{0}-rg" -f $Name)
    }
    Write-Verbose ("Service {0} v{1} deployed" -f $Name, $Version)
}
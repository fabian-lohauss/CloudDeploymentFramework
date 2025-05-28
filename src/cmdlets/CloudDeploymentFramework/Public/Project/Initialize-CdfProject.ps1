
Function Initialize-CdfProject {
    [CmdletBinding()]
    param (
        [Parameter( ParameterSetName = "Default", Mandatory)]
        [string]$Name
    )

    $ServiceFolder = Join-Path $PWD -ChildPath ".cdf"
    if (-not (Test-Path $ServiceFolder)) {
        $Folder = New-Item -Path $ServiceFolder -ItemType Directory 
        [System.IO.File]::SetAttributes($Folder.FullName, [System.IO.FileAttributes]::Directory -band [System.IO.FileAttributes]::Hidden)
    }

    $ConfigurationFile = Join-Path $ServiceFolder -ChildPath "Configuration.json"
    if (-not (Test-Path $ConfigurationFile)) {
        $Content = @{ Name = $Name } | ConvertTo-Json
        New-Item $ConfigurationFile -ItemType File -Value $Content | Out-Null
    }
}
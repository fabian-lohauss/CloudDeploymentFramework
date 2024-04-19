

function Import-CdfServiceTemplate {
    [CmdletBinding()]
    param (
        [string]$Path
    )

    $ServiceTemplateFile = Get-ChildItem $Path -Filter "*.json"
    $ServiceTemplate = Get-Content $ServiceTemplateFile | ConvertFrom-Json
    $ServiceTemplate | Add-Member -NotePropertyName Path -NotePropertyValue $Path
    return $ServiceTemplate
}
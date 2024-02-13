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
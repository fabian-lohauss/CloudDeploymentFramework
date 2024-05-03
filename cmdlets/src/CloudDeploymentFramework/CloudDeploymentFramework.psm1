
$PublicFolder = Join-Path $PSScriptRoot -ChildPath "Public"
$PublicFiles = Get-ChildItem -Path $PublicFolder -Recurse -Include *.ps1
foreach ($File in $PublicFiles) {
    $ImportedFunction += @($File.Name -replace ".ps1", "")
    . $File.FullName
}

Export-ModuleMember -Function $ImportedFunction

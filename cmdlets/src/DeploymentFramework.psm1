# dotsource all the files in the public folder and subfolders

$PublicFolder = Join-Path $PSScriptRoot -ChildPath "Public"
$PublicFiles = Get-ChildItem -Path $PublicFolder -Recurse -Include *.ps1
foreach ($File in $PublicFiles) {
    $ImportedFunction += @($File.Name -replace ".ps1", "")
    . $File.FullName
}

# Export the public functions
Export-ModuleMember -Function $ImportedFunction

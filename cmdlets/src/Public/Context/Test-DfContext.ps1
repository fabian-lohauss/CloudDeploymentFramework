function Test-DfContext {
    [CmdletBinding()]
    param(  )

    $CmdletContextConnected = $false
    $CmdletContext = Get-AzContext
    if ($CmdletContext) {
        $CmdletContextConnected = $true
    }

    $AzContextConnected = $false
    $AzContext = az account list --only-show-errors | ConvertFrom-Json
    if ($null -ne $AzContext) {
        $AzContextConnected = $true
    }

    $ContextConnected = $CmdletContextConnected -and $AzContextConnected

    return $ContextConnected
}
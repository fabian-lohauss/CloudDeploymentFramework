Function Get-CdfPublicIp {
    <#
    .SYNOPSIS
    Get the public IP address of the current machine.

    .DESCRIPTION
    Get the public IP address of the current machine.

    .EXAMPLE
    Get-CdfPublicIp
    #>
    [CmdletBinding()]
    param()

    $publicIp = (Invoke-WebRequest -Uri "http://ipinfo.io/ip" -UseBasicParsing).Content.Trim()
    return $publicIp
}
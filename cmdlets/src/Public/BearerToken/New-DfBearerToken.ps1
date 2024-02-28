function New-DfBearerToken {
    try {
        $context = Get-AzAccessToken
    } catch {
        throw "Failed to get bearer token: $_"
    }
    $accessToken = $context.Token
    return "Bearer $accessToken"
}
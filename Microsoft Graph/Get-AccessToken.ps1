function Get-AccessToken {
    Param(
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Client ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientId,
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Client Secret.")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientSecret,
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Tenant ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$Tenant
    )
    
    # Populate body request with credentials and information
    $body = @{
        grant_type    = 'client_credentials'
        client_id     = $ClientId
        scope         = 'https://graph.microsoft.com/.default'
        client_secret = $ClientSecret
    }
    $contentType = 'application/x-www-form-urlencoded'
    $URI = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    
    # Request access token from the Azure AD tenant and convert to to PSObject
    $request = Invoke-WebRequest -Method POST -Uri $URI -Body $body -ContentType $contentType -UseBasicParsing -ErrorAction Stop
    $token = $request | ConvertFrom-Json
    Return $token.access_token
}
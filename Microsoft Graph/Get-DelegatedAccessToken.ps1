function Get-DelegatedAccessToken {
    Param(
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Client ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientID,
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Tenant ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$Tenant
    )

    # Resource that we want to get an access token from
    $resource = "https://graph.microsoft.com/"

    # Required parameters to request a device code using OAuth 2.0
    $deviceCodeRequestParams = @{
        Method = 'POST'
        Uri    = "https://login.microsoftonline.com/$Tenant/oauth2/devicecode"
        Body   = @{
            client_id = $ClientID
            resource  = $resource
        }
    }
    
    $deviceCodeRequest = Invoke-RestMethod @deviceCodeRequestParams
    Write-Host $deviceCodeRequest.message -ForegroundColor Yellow
    
    $confirmation = Read-Host "Authenticated with a device code? Press Y to continue"
    
    # If user pressed Y or Yes, continue with the rest of the script
    if ($confirmation -eq 'Y' -or "Yes") {
        
        # Required parameters to request an access token using OAuth 2.0
        $tokenRequestParams = @{
            Method = 'POST'
                Uri    = "https://login.microsoftonline.com/$Tenant/oauth2/token"
                Body   = @{
                    grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                    code       = $deviceCodeRequest.device_code
                    client_id  = $ClientID
                }
            }
    
            # Try to get the final access token for the Graph API using the device code generated from the previous request
            try {
                $tokenRequest = Invoke-RestMethod @TokenRequestParams -ErrorAction Stop
            }
            catch {
                Write-Error "Could not retrieve access token from the application. Check Allow public client flows settings and Mobile and desktop applications redirect URI"
            }

            # Return the access token to the user
            Return $tokenRequest.access_token
    }
    
    else {
        Write-Warning "You did not press Yes. Exiting function"
    }
}
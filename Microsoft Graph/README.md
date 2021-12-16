# Microsoft Graph
These functions provide functionality to connect with Microsoft Graph using an Enterprise Application in Azure AD.

* Get-AccessToken.ps1 will authenticate with Microsoft Graph using a Client ID, Client Secret and Tenant ID from an Enterprise Application and returns an access token.
* Invoke-MicrosoftGraph.ps1 can be leveraged to query Microsoft Graph endpoints combined with the access token generated from Get-AccessToken.ps1

New-AccessToken.ps1
-------------------------
1. Create an Enterprise Application in Azure AD and give the required Enterprise permissions.
2. Make sure you have an Client ID, Client Secret and Tenant ID retrieved from that Enterprise Application.
3. Load New-AccessToken.ps1 inside your script or console.
4. Now execute the function: ```New-AccessToken -ClientID 'YourClientIDHere' -ClientSecret 'SuperSecretHere' -Tenant 'TenantIDHere'```
5. This will return an access token that can be used. This token is valid for 15 minutes.

New-DelegatedAccessToken.ps1
-------------------------
1. Create an Enterprise Application in Azure AD and give the required Delegated permissions.
2. Make sure you have an Client ID and Tenant ID retrieved from that Enterprise Application.
3. It is required to enable the native redirect URI for Mobile and desktop applications and set Allow public client flows to Yes.
4. Load New-DelegatedAccessToken.ps1 inside your script or console.
5. Now execute the function: ```New-DelegatedAccessToken -ClientID 'YourClientIDHere' -ClientSecret -Tenant 'TenantIDHere'```
6. This will require you to login with user credentials. After authenticating sucessfully, an access token is returned. This token is valid for 15 minutes.

Invoke-MicrosoftGraph.ps1
-------------------------
1. Run New-AccessToken.ps1 first to retrieve an access token.
3. Load Invoke-MicrosoftGraph.ps1 inside your script or console.
4. GET example: ```Invoke-MicrosoftGraph -Endpoint 'users' -Method 'GET' -AccessToken 'AccessTokenHere'```
4. POST example: ```Invoke-MicrosoftGraph -Endpoint 'groups' -Body 'JsonObject' -Method 'POST' -AccessToken 'AccessTokenHere'```

Disclaimer
----------
The scripts provided in this project is an open source example and should not be treated as an officially supported product. Use at your own risk.
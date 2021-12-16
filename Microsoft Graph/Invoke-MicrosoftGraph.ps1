function Invoke-MicrosoftGraph {

    Param(
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid access token for the Enterprise App")]
        [ValidateNotNullOrEmpty()]
        [String]$AccessToken,

        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Graph endpoint")]
        [ValidateNotNullOrEmpty()]
        [String]$Endpoint,

        [parameter(Mandatory = $true,
            HelpMessage = "Provide a method. This can be GET or POST")]
        [ValidateNotNullOrEmpty()]
        [String]$Method,

        [parameter(Mandatory = $false,
            HelpMessage = "Provide a body for the request")]
        [ValidateNotNullOrEmpty()]
        [Object]$Body,
        
        [parameter(Mandatory = $false,
            HelpMessage = "Use this parameter if you want the beta version of the API.")]
        [ValidateNotNullOrEmpty()]
        [Switch]$Beta
    )

    # Use the Graph Beta API when the switch parameter is used
    if ($Beta -eq $true) {
        $baseURI = "https://graph.microsoft.com/beta/"
    } else {
        $baseURI = "https://graph.microsoft.com/v1.0/"
    }

    # Combine the base URI and the Endpoint URL
    $URI = $baseURI + $Endpoint

    # Send a body with the request when the body parameter is used
    if ($Body) {
        # Request access token from the Azure AD tenant and convert to to PSObject
        $request = Invoke-RestMethod -Method $Method -Uri $URI -Body $Body -Headers @{ 'Authorization' = "Bearer $AccessToken" } -ContentType 'application/json' -ErrorAction Stop
    }

    else {
        # Request access token from the Azure AD tenant and convert to to PSObject
        $request = Invoke-RestMethod -Method $Method -Uri $URI -Headers @{ 'Authorization' = "Bearer $AccessToken" } -ErrorAction Stop
    }

    # Get the value of the first response
    $output = $request.value

    # Get the URL for the next page if there is one. There is always NextLink property even if there is one page
    $requestNextLink = $request."@odata.nextLink"

    while ($requestNextLink) {
        $requestResponse = Invoke-RestMethod –Method $Method -Uri $requestNextLink -Headers @{ 'Authorization' = "Bearer $AccessToken" } -ErrorAction Stop
        $requestNextLink = $requestResponse."@odata.nextLink"
        $output += $requestResponse.value
    }

    Return $output
}
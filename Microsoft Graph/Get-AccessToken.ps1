function Get-AccessToken {
    Param(
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Client ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$Certificate,
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Client ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientId,
        [parameter(Mandatory = $false,
            HelpMessage = "Provide a valid Client Secret.")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientSecret,
        [parameter(Mandatory = $true,
            HelpMessage = "Provide a valid Tenant ID.")]
        [ValidateNotNullOrEmpty()]
        [String]$Tenant
    )

    if ($Certificate -and $ClientSecret) {
        <#condition#>
    }

    elseif ($Certificate) {
        # Create a Base64 hash from the certificate
        $certificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())

        # Create JWT timestamp for expiration
        $startDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
        $JWTExpirationTimeSpan = (New-TimeSpan -Start $startDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds  
        $JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)
 
        # Create JWT validity start timestamp
        $notBeforeExpirationTimeSpan = (New-TimeSpan -Start $startDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
        $notBefore = [math]::Round($notBeforeExpirationTimeSpan,0)
 
        # Create JWT header
        $JWTHeader = @{
            alg = "RS256"
            typ = "JWT"
            x5t = $certificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='
        }
 
        # Create JWT payload
        $JWTPayLoad = @{
            aud = "https://login.microsoftonline.com/$Tenant/oauth2/token"
            exp = $JWTExpiration
            iss = $ClientId
            jti = [guid]::NewGuid()
            nbf = $notBefore
            sub = $ClientId
        }
 
        # Convert header and payload to base64
        $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
        $encodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)
        $JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
        $encodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)
 
        # Join header and Payload with "." to create a valid (unsigned) JWT
        $JWT = $encodedHeader + "." + $encodedPayload
 
        # Get the private key object of your certificate
        $privateKey = $Certificate.PrivateKey
 
        # Define RSA signature and hashing algorithm
        $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
        $hashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
 
        # Create a signature of the JWT
        #########################
        $signature = [Convert]::ToBase64String(
            $privateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$hashAlgorithm,$RSAPadding)
        ) -replace '\+','-' -replace '/','_' -replace '='
 
        # Join the signature to the JWT with "."
        ###############################
        $JWT = $JWT + "." + $signature
 
        # Use the self-generated JWT as Authorization to get the Access Token
        $header = @{
            Authorization = "Bearer $JWT"
        }

        $scope = "https://graph.microsoft.com/.default"
        $body = @{
            client_id = $ClientId
            client_assertion = $JWT
            client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
            scope = $scope
            grant_type = "client_credentials"
        }
 
    $authUri = "https://login.microsoftonline.com/common/oauth2/token"
    
    $TokenResponse = Invoke-RestMethod -Header $header -Uri $authUri -Method POST -Body $Body
 

    }

    elseif ($ClientSecret) {
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
}

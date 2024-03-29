function global:New-PartnerAccessTokenLW {
    param (
        [String]$ApplicationId,
        [PSCredential]$Credential,
        [String]$RefreshToken,
        [String]$Scopes,
        [string]$Tenant
    )
	
    if ($Credential) {
		$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.password)
		$AppPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        $AuthBody = @{
            client_id     = $ApplicationId
            scope         = $Scopes
            refresh_token = $RefreshToken
            grant_type    = "refresh_token"
            client_secret = $AppPassword
        }
    }
    else {
        $AuthBody = @{
            client_id     = $ApplicationId
            scope         = $Scopes
            refresh_token = $RefreshToken
            grant_type    = "refresh_token"
        }
    }

    if ($tenant) {
        $Uri = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }
    else {
        $Uri = "https://login.microsoftonline.com/common/oauth2/v2.0/token"  
    }


    try {
        $ReturnCred = (Invoke-WebRequest -uri $Uri -ContentType "application/x-www-form-urlencoded" -Method POST -Body $AuthBody -ea stop).content | convertfrom-json
    }
    catch {
        Write-Error "Authentication Error Occured $_"
        return
    }

    $ParsedCred = @{
        AccessToken = $ReturnCred.Access_Token
    }

    Return $ParsedCred

}
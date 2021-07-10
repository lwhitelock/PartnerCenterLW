function global:New-PartnerAccessTokenLW {
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName = 'Credentials')]
        [Parameter(Mandatory = $true,
        ParameterSetName = 'RefreshTokenOnly')]
        [String]$ApplicationId,

        [Parameter(Mandatory = $true,
        ParameterSetName = 'Credentials')]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $true,
        ParameterSetName = 'Credentials')]
        [Parameter(Mandatory = $true,
        ParameterSetName = 'RefreshTokenOnly')]
        [String]$RefreshToken,

        [Parameter(Mandatory = $true,
        ParameterSetName = 'Credentials')]
        [Parameter(Mandatory = $true,
        ParameterSetName = 'RefreshTokenOnly')]
        [String]$Scopes,
        
        [Parameter(ParameterSetName = 'Credentials')]
        [Parameter(ParameterSetName = 'RefreshTokenOnly')]
        [string]$Tenant
    )
	
    if ($Credential) {
		$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.password)
		$AppPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
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
    }

    $ParsedCred = @{
        AccessToken = $ReturnCred.Access_Token
    }

    Return $ParsedCred

}
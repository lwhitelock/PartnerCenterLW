# PartnerCenterLW

This is a simple module that implements the New-PartnerAccessToken command for the secure application model. This allows MSPs to run the vast magority of M365 scripts without having to load the full module. This provides PSCore compatibility and stops the conflicts between Partner Centre and other modules. It is designed to be a drop in replacement only needing you to add LW to existing PartnerCenter references.
  

# Installation instructions

This module has been published to the PowerShell Gallery. In your script edit:  

    "install-module PartnerCenter" to be "install-module PartnerCenterLW"
    "import-module PartnerCenter" to be "import-module PartnerCenterLW"

No other changes should be needed.


# Usage
  
**Examples:**
For more context on how to use these commands I suggest you check out https://www.cyberdrain.com/ or my blog https://mspp.io 

Obtain an Azure AD Graph Token for your Tenant or a customer tenant
```powershell
Import-Module PartnerCenterLW
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$CustAadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes "https://graph.windows.net/.default" -ServicePrincipal -Tenant $customer.CustomerContextId
```

Obtain a Graph Token for your Tenant or a customer tenant
```powershell
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
$CustGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes "https://graph.microsoft.com/.default" -ServicePrincipal -Tenant $customer.CustomerContextId
```

Obtain an Exchange Online Token for a client
```powershell
$token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.CustomerContextId
```

Alerternatively you can Paste the function directly in your code to avoid having to import the module at all
```powershell
function New-PartnerAccessToken {
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName = 'Credentials')]
        [Parameter(Mandatory = $true,
        ParameterSetName = 'RefreshTokenOnly')]
        [String]$ApplicationId,

        [Parameter(ParameterSetName = 'Credentials')]
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
```



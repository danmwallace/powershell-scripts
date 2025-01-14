$TenantID = ""

# Connect to Microsoft Graph with required permissions
Connect-MgGraph -TenantID $TenantID -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All"

# Get all users
$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName

# Initialize arrays to store results
$mfaReport = @()
$authMethodReport = @()

foreach ($user in $users) {
    Write-Host "Processing user: $($user.UserPrincipalName)"
    
    # Get authentication methods for the user
    $authMethods = Get-MgUserAuthenticationMethod -UserId $user.Id
    
    # Check if user is MFA enabled
    $isMfaEnabled = $false
    $phoneAuth = $false
    $appAuth = $false
    
    foreach ($method in $authMethods) {
        $methodType = $method.AdditionalProperties["@odata.type"]
        
        if ($methodType -in "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod", 
                           "#microsoft.graph.phoneAuthenticationMethod",
                           "#microsoft.graph.fido2AuthenticationMethod") {
            $isMfaEnabled = $true
        }
        
        if ($methodType -eq "#microsoft.graph.phoneAuthenticationMethod") {
            $phoneAuth = $true
        }
        
        if ($methodType -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod") {
            $appAuth = $true
        }
    }
    
    # Add to MFA report
    $mfaReport += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName = $user.DisplayName
        MFAEnabled = $isMfaEnabled
    }
    
    # Add to authentication method report
    $authMethodReport += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName = $user.DisplayName
        UsingPhoneAuth = $phoneAuth
        UsingAppAuth = $appAuth
    }
}

# Export reports to CSV
$mfaReport | Export-Csv -Path "MFAEnrollmentReport.csv" -NoTypeInformation
$authMethodReport | Export-Csv -Path "AuthMethodReport.csv" -NoTypeInformation

Write-Host "Reports generated: MFAEnrollmentReport.csv and AuthMethodReport.csv"
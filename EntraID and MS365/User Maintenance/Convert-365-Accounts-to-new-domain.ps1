# This script is intended to be executed by RunBatches.ps1
# To execute manually, you will need to pass the argument -UserList, i.e:
# ./Make-Zoom-Account-Changes.ps1 -UserList .\Batches\Test-Users.csv

# Note: SMTP needs updating to use MS Graph and a self-signed cert via server
# You will need to create an App Registration to send email.
# See here for a detailed guide: https://www.gitbit.org/course/ms-500/blog/how-to-send-emails-through-microsoft-365-from-powershell-injifle8u

# Parameters below are meant to be passed in with this script, i.e:
# ./Make-365-UPN-Changes.ps1 -UserList [file.csv] -UPN myaccount@domain.com -Organization mydomain.onmicrosoft.com -TenantID TenantIDFromEntraID -ClientID [ClientIDForAppRegistration] -CertThumbprint [ThumbprintFromCert]
# Note: You MUST use the .onmicrosoft.com domain in your tenant

$MyUPN = "YourUPN@somedomain"
$TenantID = ""
$Organization = "somedomain.onmicrosoft.com"
$CertThumbprint = "CertThumbPrint - See SMTP Guide above"
$ClientID = ""
$SenderEmail = "itsupport@somedomain.com"

$Users = Import-CSV ".\RevertChanges\Revert-Test-Users.csv"
$CompletedChanges = ".\results\CompletedUPNChanges.csv"
$FailedChanges = ".\results\FailedUPNChanges.csv"

Import-Module Microsoft.Graph 
Import-Module ExchangeOnlineManagement

$CompletedUPNChanges = @()
$FailedUPNChanges = @()

Connect-MgGraph -TenantID $TenantID -clientID $ClientID -NoWelcome -CertificateThumbprint $CertThumbprint
Connect-ExchangeOnline -UserPrincipalName $UPN -Organization $Organization #Used for Set-Mailbox to add an email alias, as MSGraph doesn't support this yet

# Loop through each user and update the UPN

foreach ($User in $Users) {
    Write-Host "Changing user inbox (UPN)" $User.UserPrincipalName "to" $User.NewUPN
    try {
        Update-MgUser -UserId $User.UserPrincipalName -UserPrincipalName $User.NewUPN
        try {
            Write-Host "Adding " $User.UserPrincipalName " as email alias to prevent disruption to mail routing"
            Set-Mailbox -Identity $User.NewUPN -EmailAddresses @{Add=$User.UserPrincipalName}
            $CompletedUPNChanges = [PSCustomObject]@{
                UPN = $User.UserPrincipalName
                NewUPN = $User.NewUPN
            }
        }
        catch { 
            Write-Host "No mailbox for user " $User.UserPrincipalName
        }
    }
    catch {
        Write-Host "Failed to update:" $User.UserPrincipalName -ForegroundColor Red
        $FailedUPNChanges = [PSCustomObject]@{
            UPN = $User.UserPrincipalName
            FailedUPN = $User.NewUPN
        }
    }
}

# Export reports
$CompletedUPNChanges | Export-CSV -Path $CompletedChanges -NoTypeInformation -Delimiter ","
$FailedChanges | Export-CSV -Path $FailedChanges -NoTypeInformation -Delimiter ","

# Wait 30 seconds and wrap up to send notifications to end users
Start-Sleep -seconds 30

foreach ($changedUser in $CompletedUPNChanges) {
    Write-Host "Sending email to " $CompletedUPNChanges.NewUPN " to notify them of change"
    $SMTPMessage = @{
        subject = "Notice: Your email address has changed to " + $CompletedUPNChanges.NewUPN;
        toRecipients = @(@{
            emailAddress = @{
                address = $CompletedUPNChanges.NewUPN;
            };
        });
        body = @{
            contentType = "HTML";
            content = "Greetings,<br /><br /><b>Please note that your email address has changed.</b><br /><br /><b>If you experience any issues or have any questions, please contact us.</b>"
        }
    }
    # Can optionally add a -CC [email] flag
    Send-MgUserMail -UserID $SenderEmail -Message $SMTPMessage
}

Disconnect-ExchangeOnline
Disconnect-MgGraph
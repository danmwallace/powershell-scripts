# Variables 
# Specify the .CSV to fetch the proposed changes under the $users variable
# Specify the location you want the reports to be exported to (for changed UPNs and failures) on $completedChanges and $failedChanges respectively

# Note: SMTP needs updating to use MS Graph and a self-signed cert via server
# You will need to create an App Registration to send email: https://www.gitbit.org/course/ms-500/blog/how-to-send-emails-through-microsoft-365-from-powershell-injifle8u

Install-Module Microsoft.Graph
Install-Module ExchangeOnlineManagement

$users = Import-CSV ".\Batches\Test-Users.csv"

# Tenant/Org Configuration Settings. Modify provided examples as needed. You will need to supply the Certificate Thumb Print and Client ID for the app registration you created
$MyUPN = ""
$TenantID = ""
$organization = "somedomain.onmicrosoft.com" # Needed because ExchangeOnline does not support Tenant ID
$SenderEmail = "someemail@somedomain.com"
$certThumbprint = ""
$clientID = ""

Connect-MgGraph -TenantID $TenantID -clientID $clientID -NoWelcome -CertificateThumbprint $certThumbprint
Connect-ExchangeOnline -UserPrincipalName $MyUPN -Organization $organization #Used for Set-Mailbox to add an email alias, as MSGraph doesn't support this yet

# Loop through each user and update the UPN
foreach ($user in $users) {
    Write-Host "Sending email to " $user.UserPrincipalName " to notify them of upcoming change"
    $smtpMessage = @{
        subject = "Notice: Your email address is changing to " + $user.NewUPN + " tomorrow. Here's what you need to know.";
        toRecipients = @(@{
            emailAddress = @{
                address = $user.UserPrincipalName;
            };
        });
        body = @{
            contentType = "HTML";
            content = "Greetings,<br /><br />Please note that your email address will be changing this evening. <b>Your new email address will be <i>" + $user.NewUPN + "</b></i>. Here are some things you should know:<ul><li>After the change is made, you will need to sign into Outlook and Microsoft Office with your new email address.</li><li>Your password to Microsoft 365 (Outlook) will not be changed.</li><li>You will still be able to access your PC (if equipped) without issue.</li><li>You may need to sign back into Mobile Apps, such as Outlook on your phone, if used.</li><li><b>You will still receive email addressed for your old account</b></li></ul><br />If you experience any issues or have any questions, <b>please reply to this email or create a new ticket request by contacting us.</b><br /><br />"
        }
    }
    Send-MgUserMail -UserID $SenderEmail -Message $smtpMessage
}

Disconnect-ExchangeOnline
Disconnect-MgGraph
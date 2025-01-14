###########################################
# Convert-Box-Accounts.ps1
#
# This script references a .csv and will convert the email addresses for users on Box.com to a new email and also pass the --confirm flag so that they can login 
# and don't need to manually confirm the change via a notification email that requires their confirmation.
#
# You will need Box CLI for this to work
# See here: https://github.com/box/boxcli

$UserList = ".\Batches\Box-Test-Users.csv"
$Users = Import-CSV $UserList

foreach ($User in $Users) {
    try{ 
        $addBoxAlias = "box users:email-aliases:add $($User.id) $($User.NewUPN) --confirm"
        $addBoxAliasResult = Invoke-Expression $addBoxAlias
        $updateBoxEmail = "box users:update $($User.id) --login=$($User.NewUPN)"
        $updateBoxEmailResult = Invoke-Expession $UpdateBoxEmail
    }
    catch {
        Write-Host "Issue changing " $User.login " to " $User.NewUPN
    }
}
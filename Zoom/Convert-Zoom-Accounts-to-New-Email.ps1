# This script is intended to be executed by RunBatches.ps1
# To execute manually, you will need to pass the argument -UserList, i.e:
# ./Make-Zoom-Account-Changes.ps1 -UserList .\Batches\Test-Users.csv

Import-Module PSZoom

$UserList = "./RevertChanges/Revert-Test-Users.csv"
$AccountID = ""
$ClientID = ""
$ClientSecret = ""
$Users = Import-CSV $UserList


Connect-PSZoom -AccountID $AccountID -ClientID $ClientID -ClientSecret $ClientSecret

foreach ($User in $Users) {
    try {
        Update-ZoomUserEmail -UserId $User.UserPrincipalName -Email $User.NewUPN -Passthru
    }
    catch {
        Write-Host "Could not update account for " $User.UserPrincipalName
    }
}

$TenantID = "4035b9e9-116b-47d8-85f0-e595f3c97fcb"

Connect-MgGraph -TenantID $TenantID -Scopes "AuditLog.Read.All", "Directory.Read.All"

#Get-MgAuditLogSignIn -Filter "Location/CountryOrRegion ne 'United States'" -All | Select-Object CreatedDateTime, UserPrincipalName, Location, IPAddress | Export-Csv -Path "NonUSSignIns.csv" -NoTypeInformation

Get-MgAuditLogSignIn -Filter "Location/CountryOrRegion ne 'US'" -All
   | Select-Object -Property CreatedDateTime, UserPrincipalName, IPAddress, @{Name=“City”;Expression={$_.Location.City}}, @{Name=“Country/Region”;Expression={$_. Location.CountryOrRegion}}, @{Name=“State”;Expression={$_.Location.State}}, @{Name=“ErrorCode”;Expression={$_.Status.ErrorCode}}, @{Name=“FailureReason”;Expression={$_.Status.FailureReason}} 
   | Export-Csv -Path "~/Downloads/NonUSSignIns.csv" -NoTypeInformation

#To know which properties exist for an object, you can display the members of the object as follows:
#$signIn = Get-MgAuditLogSignIn | Select-Object -First 1
#$signIn.Location | Get-Member
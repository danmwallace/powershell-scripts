$TenantID = ""

Connect-MgGraph -TenantID $TenantID -Scopes "AuditLog.Read.All", "Directory.Read.All"

Get-MgAuditLogSignIn -Filter "Location/CountryOrRegion ne 'US'" -All
   | Select-Object -Property CreatedDateTime, UserPrincipalName, IPAddress, @{Name=“City”;Expression={$_.Location.City}}, @{Name=“Country/Region”;Expression={$_. Location.CountryOrRegion}}, @{Name=“State”;Expression={$_.Location.State}}, @{Name=“ErrorCode”;Expression={$_.Status.ErrorCode}}, @{Name=“FailureReason”;Expression={$_.Status.FailureReason}} 
   | Export-Csv -Path "~/Downloads/NonUSSignIns.csv" -NoTypeInformation
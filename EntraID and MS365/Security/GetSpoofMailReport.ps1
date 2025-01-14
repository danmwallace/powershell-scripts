Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline

Get-SpoofMailReport -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date)
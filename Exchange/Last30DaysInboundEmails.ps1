##############################################################
# TotalInboundEmails.ps1
#
# This will provide a report of the email activity on a domain

$TenantID = ""
$ReportName = "EmailActivity.csv"
$domain = "example.com"

Install-Module Microsoft.Graph -Scope CurrentUser

Connect-MgGraph -TenantID $TenantID -Scopes "Reports.Read.All"

$startDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
$endDate = Get-Date -Format "yyyy-MM-dd"
$report = Get-MgReportEmailActivityCount -Period 'D30' -OutFile $ReportName

$data = Import-Csv $ReportName
$totalSent = ($data | Where-Object { $_.RecipientAddress -like "*@$domain" } | Measure-Object -Property SendCount -Sum).Sum

Write-Output "Total emails sent to $domain in the last 30 days: $totalSent"
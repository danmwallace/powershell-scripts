Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "SecurityEvents.Read.All"

# Set the date range
$startDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
$endDate = Get-Date -Format "yyyy-MM-dd"

# Retrieve risky sign-ins
$riskySignIns = Get-MgRiskySignIn -Filter "riskState eq 'atRisk' and riskLevel eq 'high'" -Top 1000

# Process and display the results
$riskySignIns | Select-Object @{N='UserPrincipalName';E={$_.UserDisplayName}},
    @{N='SignInDateTime';E={$_.RiskEventTypes[0].RiskEventDateTime}},
    @{N='IPAddress';E={$_.IpAddress}},
    @{N='Location';E={$_.Location.City + ", " + $_.Location.CountryOrRegion}},
    RiskLevel,
    RiskState,
    @{N='RiskEventTypes';E={$_.RiskEventTypes -join ', '}} |
    Format-Table -AutoSize
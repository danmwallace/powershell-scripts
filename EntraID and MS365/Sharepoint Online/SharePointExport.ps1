# Connect to SharePoint Online

$TenantID = ""
Connect-SPOService -TenantID $TenantID

# Get all SharePoint sites
$sites = Get-SPOSite -Limit All

# Create an array to store the results
$results = @()

forEach ($site in $sites) {
    # Get site admins
    $siteAdmins = Get-SPOUser -Site $site.Url | Where-Object { $_.IsSiteAdmin -eq $true }

    # Get all site users (admins and members)
    $allSiteUsers = Get-SPOUser -Site $site.Url

    # Extract the unique domains from all site users' UPNs, only if LoginName contains "@" and is not "sharepoint.com"
    $memberDomains = $allSiteUsers.LoginName | ForEach-Object {
        if ($_ -match "@" -and $_ -notlike "*@sharepoint.com") {
            ($_ -split '@')[1]
        }
    } | Select-Object -Unique

    # Create a custom object with the required information
    $siteInfo = [PSCustomObject]@{
        SiteName = $site.Title
        SiteUrl = $site.Url
        StorageUsed = [math]::Round($site.StorageUsageCurrent / 1024, 2) # Convert to MB
        SiteAdmins = ($siteAdmins.LoginName -join ', ')
        MemberDomains = ($memberDomains -join ', ')
    }

    $results += $siteInfo
}

# Export results to CSV
$results | Export-Csv -Path "SharePointSiteInfo.csv" -NoTypeInformation

# Display results in console
$results | Format-Table -AutoSize
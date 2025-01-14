# Audit Script
# This script can be used to iterate through a reference list and compare it to another list
# Useful for finding out if you need to remove users from a service
# In example: You export Users from JIRA and want to make sure there are no accounts which do not exist in Google Workspace (IDP)
#             With this script, you would attach the JIRA export as the ReferenceObject list, and the Google Workspace 



#$difference = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2


Import-CSV -Path $referencecsv | ForEach {
    $referencelist.Add('$._UserPrincipalName')
}

Write-Output $referencelist[1]

#foreach ($item in $difference) {
#    if ($item.SideIndicator -eq "=>") {
#        Write-Output $item.InputObject
#    }
#}
##############################################################
# Copy Power Bi Workspace (.pbix) from one tenant to another
##############################################################
# To use:
# - $TenantID = Source Tenant ID
# - $DestinationTenantID = Destination Tenant ID
# - $reportID = ObjectID of report 
# - $exportPath = The path to the report/.pbix file
# - $workspaceId = the workspace ID for the PowerBi workspace we're pulling the report from


# Install the Power BI Management module
$TenantID = ""
$DestinationTenantID = ""
$reportId = ""
$exportPath = "Some PowerBi Report.pbix"
$workspaceId = ""

Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -AllowClobber -Force

$spName = "MyServicePrincipal"
$sp = New-AzADServicePrincipal -DisplayName $spName

# Login and authenticate with the Source Tenant
Connect-PowerBIServiceAccount -TenantId $TenantID -Credential $credential
 
# Function to export the .pbix file
function Export-Pbix {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ReportId,
 
        [Parameter(Mandatory=$true)]
        [string]$ExportPath
    )
 
    $export = Export-PowerBIReport -Id $ReportId -OutFile $ExportPath
 
    if ($export) {
        Write-Output "Export succeeded: $(Get-Date)"
    } else {
        Write-Error "Export failed: $(Get-Date)"
    }
}
 
# Function to import the .pbix file
function Import-Pbix {
    param (
        [Parameter(Mandatory=$true)]
        [string]$WorkspaceId,
 
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
 
    $import = Import-PowerBIReport -Path $FilePath -WorkspaceId $WorkspaceId
 
    if ($import) {
        Write-Output "Import succeeded: $(Get-Date)"
    } else {
        Write-Error "Import failed: $(Get-Date)"
    }
}

 
# Export the report from the Source Tenant
Export-Pbix -ReportId $reportId -ExportPath $exportPath
 
# Logout from the Source Tenant
Disconnect-PowerBIServiceAccount
 
# Login and authenticate with the Destination Tenant
Connect-PowerBIServiceAccount -TenantId $DestinationTenantID
 
# Import the report to the Destination Tenant
Import-Pbix -WorkspaceId $workspaceId -FilePath $exportPath
 
# Logout from the Destination Tenant
Disconnect-PowerBIServiceAccount
 
Write-Output "Completed moving .pbix file from one tenant to another."
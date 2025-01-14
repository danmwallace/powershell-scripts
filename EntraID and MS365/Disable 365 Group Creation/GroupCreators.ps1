$TenantID = ""

Import-Module Microsoft.Graph.Beta.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Beta.Groups

Connect-MgGraph -TenantID -Scopes "Directory.ReadWrite.All", "Group.Read.All"

$GroupName = "Microsoft 365 Group and Teams Creators"
$AllowGroupCreation = "False"

$settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id

if(!$settingsObjectID)
{
    $params = @{
	  templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
	  values = @(
		    @{
			       name = "EnableMSStandardBlockedWords"
			       value = "true"
		     }
	 	     )
	     }
	
    New-MgBetaDirectorySetting -BodyParameter $params
	
    $settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).Id
}

 
$groupId = (Get-MgBetaGroup -All | Where-object {$_.displayname -eq $GroupName}).Id

$params = @{
	templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
	values = @(
		@{
			name = "EnableGroupCreation"
			value = $AllowGroupCreation
		}
		@{
			name = "GroupCreationAllowedGroupId"
			value = $groupId
		}
	)
}

Update-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID -BodyParameter $params

(Get-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID).Values
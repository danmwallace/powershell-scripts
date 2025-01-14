# Disable Microsoft 365 Group Creation for Users

This script is pulled from Microsoft's documentation:

To use:
* Create a group named "Microsoft 365 Group and Teams Creators"
* Add users you want to retain this capability (to create 365 groups)
* Run the script

The script was adjusted to use `Get-MgBetaGroup` with the `-All` flag, to fix an issue where there are over 100 groups in a tenant.

Official Documentation from MS: https://learn.microsoft.com/en-us/microsoft-365/solutions/manage-creation-of-groups?view=o365-worldwide
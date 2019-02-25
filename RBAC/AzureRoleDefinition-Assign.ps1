# Input variables: set these values in the variables section of the release pipeline.
#   SubscriptionID  - [required] Subscription ID
#   GroupName       - [required] Name of Azure AD group
#   roleName        - [required] Name of RBAC Role

param([string] $subscriptionId = "",
      [string] $roleName="",
      [string] $groupName="")


$ObjectID = Get-AzureRMADGroup -SearchString $GroupName
$roleinfo = Get-AzureRmRoleAssignment -RoleDefinitionName $rolename -ObjectId $ObjectID.Id

Write-Host "Creating Role Assignment, Group = $GroupName, Role = $RoleName" -ForegroundColor Yellow;

If ($roleinfo)  
                { 
                    Write-Host "Role Assignment Exists - Do Nothing" -ForegroundColor Yellow;


                }
Else

                {
                    Write-Host "Role Assignment Does Not Exist - Creating New Role Assignment" -ForegroundColor Yellow;
                    New-AzureRmRoleAssignment -ObjectId $ObjectID.Id -RoleDefinitionName $RoleName -Scope /subscriptions/$subscriptionId;
                }


               
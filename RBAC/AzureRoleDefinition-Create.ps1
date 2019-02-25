# Input variables: set these values in the variables section of the release pipeline.
#   inputFile       - [required] Role definition file path to a file containing JSON role definition file
#   roleName        - [required] Role name 

param([string] $inputFile = "",
      [string] $roleName="")


$roleinfo = Get-AzureRmRoleDefinition -Name $rolename

If ($roleinfo)  
                { 
                    Write-Host "Role Exists - Update Existing" -ForegroundColor Yellow;
                    $a = Get-Content $inputfile | ConvertFrom-Json
                    $a.id = $roleinfo.id
                    $a | ConvertTo-Json | set-content $inputfile;
                    Set-AzureRmRoleDefinition -InputFile $inputfile;

                }
Else

                {
                    Write-Host "Role does not Exist - Creating New Role Definition" -ForegroundColor Yellow;
                    New-AzureRMRoleDefinition $inputfile;
                }



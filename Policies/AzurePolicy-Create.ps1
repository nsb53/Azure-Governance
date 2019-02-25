# Input variables: set these values in the variables section of the release pipeline

#   policyName          - [required] Policy definition name
#   policyDisplayName   - [optional] Policy definition display name
#   policyDescription   - [optional] Policy definition description
#   subscriptionId      - [optional] Id of subscription the definition will be available in
#   managementGroupName - [optional] Name of management group the definition will be available in
#   policyRule          - [required] Policy definition rule in JSON string format or path to a file containing JSON policy definition rule
#   policyParameters    - [optional] Policy parameter values in JSON string format

# Notes:
#   Refer to https://docs.microsoft.com/en-us/azure/azure-policy/ for documentation on the Powershell cmdlets and the JSON input formats
#   File path value for $(PolicyRule) may be a fully qualified path or a path relative to $(System.DefaultWorkingDirectory) 
<#
$policyName = "$(policyName)"
$policyDisplayName = "$(policyDisplayName)"
$policyDescription = "$(policyDescription)"
$subscriptionId = "$(subscriptionId)"
$managementGroupName = "$(managementGroupName)"
$policyRule = "$(policyRule)"
$policyParameters = "$(policyParameters)"
#>

param(
        [string] $policyName= "",
        [string] $policyDisplayName="",
        [string] $policyDescription="",
        [string] $subscriptionId="",
        [string] $managementGroupName="",
        [string] $policyRule="",
        [string] $policyParameters=""      
      )



if (!$policyName)
{
    throw "Unable to create policy definition: required input variable value `$(PolicyName) was not provided"
}

if (!$policyRule)
{
    throw "Unable to create policy definition: required input variable value `$(PolicyRule) was not provided"
}

if ($subscriptionId -and $managementGroupName)
{
    throw "Unable to create policy definition: `$(SubscriptionId) '$subscriptionId' and `$(ManagementGroupName) '$managementGroupName' were both provided. Either may be provided, but not both."
}

$azureRMModule = (Get-Module -Name AzureRM)
if ($managementGroupName -and (-not $azureRMModule -or $azureRMModule.version -lt 6.4))
{
    throw "For creating policy as management group, Azure PS installed version should be equal to or greater than 6.4"
}

$cmdletParameters = @{Name=$policyName; Policy=$policyRule; Mode='Indexed'}
if ($policyDisplayName)
{
    $cmdletParameters += @{DisplayName=$policyDisplayName}
}

if ($policyDescription)
{
    $cmdletParameters += @{Description=$policyDescription}
}

if ($subscriptionId)
{
    $cmdletParameters += @{SubscriptionId=$subscriptionId}
}

if ($managementGroupName)
{
    $cmdletParameters += @{ManagementGroupName=$managementGroupName}
}

if ($policyParameters)
{
    $cmdletParameters += @{Parameter=$policyParameters}
}

&New-AzureRmPolicyDefinition @cmdletParameters
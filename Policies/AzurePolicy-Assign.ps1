# Input variables: set these values in the variables section of the release pipeline

#   AssignmentName        - [required] Policy assignment name
#   AssignmentDisplayName - [optional] Policy assignment display name
#   AssignmentDescription - [optional] Policy assignment description
#   PolicyName            - [optional] Name of policy definition to assign
#   PolicySetName         - [optional] Name of policy set definition to assign
#   ResourceGroupName     - [optional] Name of resource group the policy [set] definition will be applied to
#   SubscriptionId        - [optional] Id of subscription the policy [set] definition will be applied to
#   ManagementGroupName   - [optional] Name of management group the policy [set] definition will be applied to
#  PolicyParameters      - [optional] Policy parameter values in JSON string format 

# Notes:
#   Refer to https://docs.microsoft.com/en-us/azure/azure-policy/ for documentation on the Powershell cmdlets and the JSON input formats


param(
        [string] $assignmentName= "",
        [string] $assignmentDisplayName="",
        [string] $assignmentDescription="",
        [string] $policyName="",
        [string] $policySetName="",
        [string] $subscriptionId="",
        [string] $resourceGroupName="",
        [string] $managementGroupName="",
        [string] $policyParameters=""      
      )


if (!$assignmentName)
{
    throw "Unable to create policy assignment: required input variable value `$(AssignmentName) was not provided"
}

if (!$policyName -and !$policySetName)
{
    throw "Unable to create policy assignment: neither `$(PolicyName) nor `$(PolicySetName) was provided. One or the other must be provided."
}

if ($policyName -and $policySetName)
{
    throw "Unable to create policy assignment: `$(PolicyName) '$policyName' and `$(PolicySetName) '$policySetName' were both provided. Either may be provided, but not both."
}

if ($subscriptionId -and $managementGroupName)
{
    throw "Unable to create policy assignment: `$(SubscriptionId) '$subscriptionId' and `$(ManagementGroupName) '$managementGroupName' were both provided. Either may be provided, but not both."
}

if ($managementGroupName -and $resourceGroupName)
{
    throw "Unable to create policy assignment: `$(ManagementGroupName) '$managementGroupName' and `$(ResourceGroupName) '$resourceGroupName' were both provided. Either may be provided, but not both."
}

if ($managementGroupName)
{
    $scope = "/providers/Microsoft.Management/managementGroups/$managementGroupName"
    $searchParameters = @{ManagementGroupName=$managementGroupName}
}
else
{
    if (!$subscriptionId)
    {
        $subscription = Get-AzureRmContext | Select-Object -Property Subscription
        $subscriptionId = $subscription.Id
    }

    $scope = "/subscriptions/$subscriptionId"
    $searchParameters = @{SubscriptionId=$subscriptionId}
    
    if ($resourceGroupName)
    {
        $scope += "/resourceGroups/$resourceGroupName"
    }
}

$cmdletParameters = @{Name=$assignmentName; Scope=$scope}
if ($assignmentDisplayName)
{
    $cmdletParameters += @{DisplayName=$assignmentDisplayName}
}

if ($assignmentDescription)
{
    $cmdletParameters += @{Description=$assignmentDescription}
}

if ($policyName)
{
    $policyDefinition = Get-AzureRmPolicyDefinition @searchParameters | Where-Object { $_.Name -eq $policyName }
    if (!$policyDefinition)
    {
        throw "Unable to create policy assignment: policy definition $policyName does not exist"
    }

    $cmdletParameters += @{PolicyDefinition=$policyDefinition}
}

if ($policySetName)
{
    $policySetDefinition = Get-AzureRmPolicySetDefinition @searchParameters | Where-Object { $_.Name -eq $policySetName }
    if (!$policySetDefinition)
    {
        throw "Unable to create policy assignment: policy set definition $policySetName does not exist"
    }

    $cmdletParameters += @{PolicySetDefinition=$policySetDefinition}
}

if ($policyParameters)
{
    $cmdletParameters += @{PolicyParameter=$policyParameters}
}

&New-AzureRmPolicyAssignment @cmdletParameters
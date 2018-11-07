# Policy script to allow provisioning of specified resources

<#
############# Logging in to your account #############

# Connect to your account by using this command
Connect-AzureRmAccount

# Get the list of subscriptions
Get-AzureRmSubscription
# Select one of the subscriptions
Select-AzureRmSubscription <Id or Name>

######################################################
#>

Select-AzureRmSubscription Pay-As-You-Go

# Create a blank resource group to test the policy
$resourceGroupName = 'rg-policy-test'
# Create the resource group - change the location and tags as desired
New-AzureRmResourceGroup -Name $resourceGroupName -Location eastus2 -Tag @{Type='sid-test'; Group='policy'}


# Policy Creation

# To create the policy, we need to make 
# Policy related parameters
$policyName = 'allowed-resourcetypes'
$policyDisplayName = 'Allowed Resource Types'
$policyDescription = 'This policy enables you to specify the resource types that your organization can deploy.'

# Link to the JSON template for the policy - rules and parameters files
$policyRulesFile = 'https://raw.githubusercontent.com/sinigam/az-sandbox/master/policies/allowed-resourcetypes/policy.rules.json'
$policyParametersFile = 'https://raw.githubusercontent.com/sinigam/az-sandbox/master/policies/allowed-resourcetypes/policy.parameters.json'

# Name for the particular assignment of the policy
$assignmentName = 'allowedResourceTypesPolicy-test'

# Where should the policy be applied - can range from management group, subscription, resource group.
# Here, we select the test resource group we just created
$policyScope = Get-AzureRmResourceGroup -Name $resourceGroupName
# $policyScope = Get-AzureRmSubscription -SubscriptionName <Name of Subscription>
# $policyScope = Get-AzureRmManagementGroup -GroupName <Name of Management Group>

# Now, we need to create the list of allowed resource types - this is an additional parameter defined in the parameters.json file defined in the repository ($policyParametersFile)
#$listOfAllowedResourceTypes = @{'listOfResourceTypesAllowed'=(Get-AzureRmResourceProvider -ListAvailable | Select-Object ProviderNamespace)}
#$listOfAllowedResourceTypes = @{'listOfResourceTypesAllowed'=('Microsoft.Compute','Microsoft.Network')}
$listResourceTypes = @{'listOfResourceTypesAllowed'='Microsoft.Compute/availabilitySets'}
#$AllowedLocations = @{'listOfAllowedLocations'=($Locations.location)}

$definition = New-AzureRmPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -description $policyDescription -SubscriptionId 8e2b803f-ef35-4093-97e0-b190a9680de3 -Policy $policyRulesFile -Parameter $policyParametersFile -Mode All
$assignment = New-AzureRMPolicyAssignment -Name $assignmentName -Scope $policyScope -listOfResourceTypesAllowed $listResourceTypes -PolicyDefinition $definition

# Test the policy


<# Clean up
Remove-AzureRmResourceGroup -Name $resourceGroupName
#>
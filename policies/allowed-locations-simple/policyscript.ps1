# Policy script to allow provisioning of VMs in specific locations

########################### Logging in to your account, selecting a subscription, and creating a resource group ###########################

# Connect to your account once by using this command
#Connect-AzureRmAccount

# Get the list of subscriptions
#Get-AzureRmSubscription

# Select one of the subscriptions
$SubscriptionName = 'Pay-As-You-Go'

Select-AzureRmSubscription $SubscriptionName

# Store subscription id
$CurrentSubscription = Get-AzureRmSubscription -SubscriptionName $SubscriptionName

# Create a blank resource group to test the policy
$resourceGroupName = 'rg-policy-test'
# Create the resource group - change the location and tags as desired
New-AzureRmResourceGroup -Name $resourceGroupName -Location eastus -Tag @{Type='sid-test'; Group='policy'}

########################### Policy Creation ###########################

# To create the policy, we need to create the policy, then assign it to a scope
# Policy related variables
$policyName = 'allowed-locations-sid'
$policyDisplayName = 'Allowed Locations'
$policyDescription = 'This policy enables you to restrict the locations where VMs can be deployed.'
$assignmentName = 'RestrictLocationPolicyAssignment-test'

# Where should the policy be applied - can be management group, subscription, resource group.
# Here, we select the test resource group we just created
$policyScope = Get-AzureRmResourceGroup -Name $resourceGroupName
# $policyScope = Get-AzureRmSubscription -SubscriptionName <Name of Subscription>
# $policyScope = Get-AzureRmManagementGroup -GroupName <Name of Management Group>


$policy = '{
    "if": {
        "allOf": [{
                "field": "type",
                "equals": "Microsoft.Compute/VirtualMachines"
            },
            {
                "not": {
                    "field": "location",
                    "in": "[parameters(''allowedLocations'')]"
                }
            }
        ]
    },
    "then": {
        "effect": "Deny"
    }
}'

$parameters = '{
    "allowedLocations": {
        "type": "array",
        "metadata": {
            "description": "The list of locations that can be specified when deploying storage accounts.",
            "strongType": "location",
            "displayName": "Allowed locations"
        }
    }
}'

$locations = '{
    "allowedLocations":  {
      "value": [
        "eastus",
        "eastus2",
        "northeurope"
      ]
    }
}'

$definition = New-AzureRmPolicyDefinition -Name $policyName -Description $policyDescription -Policy $policy -Parameter $parameters
New-AzureRmPolicyAssignment -Name $assignmentName -DisplayName $policyDisplayName -Scope $policyScope.ResourceId -PolicyParameter $locations -PolicyDefinition $definition
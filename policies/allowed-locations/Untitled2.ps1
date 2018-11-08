# Policy script to allow provisioning in specific locations

# Instructions: Remove the '<' symbol on the head of each comment block to enable that section

########################### Logging in to your account, selecting a subscription, and creating a resource group ###########################

# Connect to your account once by using this command
Connect-AzureRmAccount

# Get the list of subscriptions
Get-AzureRmSubscription

# Select one of the subscriptions
$SubscriptionName = 'Pay-As-You-Go'

Select-AzureRmSubscription $SubscriptionName

# Store subscription id
$CurrentSubscription = Get-AzureRmSubscription -SubscriptionName $SubscriptionName

# Create a blank resource group to test the policy
$resourceGroupName = 'rg-policy-test'
# Create the resource group - change the location and tags as desired
New-AzureRmResourceGroup -Name $resourceGroupName -Location eastus2 -Tag @{Type='sid-test'; Group='policy'}

#>

########################### Policy Creation ###########################

# To create the policy, we need to create the policy, then assign it to a scope
# Policy related variables
$policyName = 'allowed-locations'
$policyDisplayName = 'Allowed Locations'
$policyDescription = 'This policy enables you to specify the locations that your organization can deploy.'

# Link to the JSON template for the policy - rules and parameters files
$policyRulesFile = 'https://raw.githubusercontent.com/sinigam/az-sandbox/master/policies/allowed-locations/policy.rules.json'
$policyParametersFile = 'https://raw.githubusercontent.com/sinigam/az-sandbox/master/policies/allowed-locations/policy.parameters.json'
$allowedLocationsFile = 'https://raw.githubusercontent.com/sinigam/az-sandbox/master/policies/allowed-locations/AllowedLocations.json'

# Name for the particular assignment of the policy
$assignmentName = 'RestrictLocationPolicyAssignment-test'

# Where should the policy be applied - can range from management group, subscription, resource group.
# Here, we select the test resource group we just created
$policyScope = Get-AzureRmResourceGroup -Name $resourceGroupName

# $policyScope = Get-AzureRmSubscription -SubscriptionName <Name of Subscription>
# $policyScope = Get-AzureRmManagementGroup -GroupName <Name of Management Group>

$definition = New-AzureRmPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Description $policyDescription -SubscriptionId $CurrentSubscription.SubscriptionId -Policy $policyRulesFile -Parameter $policyParametersFile -Mode All
$definition
$assignment = New-AzureRmPolicyAssignment -Name $assignmentName -PolicyDefinition $definition -Scope $policyScope.ResourceId -PolicyParameter $allowedLocationsFile
$assignment
#$assignment = New-AzureRmPolicyAssignment -Name 'RestrictLocationPolicyAssignment' -PolicyDefinition $Policy -Scope $ResourceGroup.ResourceId -PolicyParameter .\AllowedLocations.json

######################################################>


########################### Testing the policy ###########################

#Set this once for username and password
# $cred = Get-Credential

New-AzureRmVm `
    -ResourceGroupName $resourceGroupName `
    -Name "myVM" `
    -Location westindia `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -Credential $cred `
    -OpenPorts 80,3389

#>

<########################### Clean up ###########################

Remove-AzureRmPolicyDefinition -Name $policyName
Remove-AzureRmResourceGroup -Name $resourceGroupName

#>
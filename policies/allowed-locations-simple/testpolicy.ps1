# Policy script to allow provisioning in specific locations

# Instructions: Remove the '<' symbol on the head of each comment block to enable that section

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

########################### Testing the policy ###########################

#Set this once for username and password
$cred = Get-Credential

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

######################################################>
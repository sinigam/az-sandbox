Remove-AzureRmPolicyAssignment -Name $assignmentName -Scope $policyScope.ResourceId -Confirm:$false
Remove-AzureRmPolicyDefinition -Name $policyName -Confirm:$false
Remove-AzureRmResourceGroup -Name $resourceGroupName -Confirm:$false
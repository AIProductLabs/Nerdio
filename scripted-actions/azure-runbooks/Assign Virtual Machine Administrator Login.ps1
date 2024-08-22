#description: Adds assigned user the Virtual Machine Administrator Login role on a personal VM. Use only with personal host pools.
#execution mode: Combined
#tags: Nerdio
<#
Notes: 
This script adds the user assigned the personal desktop the Virtual Machine Administrator Login role
#>

$ErrorActionPreference = "Stop"

# Ensure correct subscription context is selected
Set-AzContext -SubscriptionId $AzureSubscriptionId | Out-Null

# Query for Azure VM object using $AzureVMName parameter, pass into $AzVM
$AzVM = Get-AzVM -Name $AzureVMName -ResourceGroupName $AzureResourceGroupName

if($DesktopUser){
  $User = Get-AzADUser -UserPrincipalName $DesktopUser

  # Assign the Virtual Machine Administrator Login role
  $RoleAssignment = New-AzRoleAssignment -ObjectId $User.Id -RoleDefinitionName "Virtual Machine Administrator Login" -Scope $AzVM.Id

  if ($RoleAssignment) {
    Write-Output "Role 'Virtual Machine Administrator Login' assigned to user $DesktopUser on VM $AzureVMName."
  } else {
    Write-Output "Failed to assign role. Please check the inputs and try again."
  }

}
else{
  Write-Output -Message 'ERROR: No Desktop User Specified. This VM may not be a personal Desktop.'
  Write-Error -Message 'ERROR: No Desktop User Specified. This VM may not be a personal Desktop.'
  exit
}
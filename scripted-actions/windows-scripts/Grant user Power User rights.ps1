#description: Adds user assigned to personal desktop to local Power Users group on session host VM. Use only with personal host pools.
#execution mode: Combined
#tags: Nerdio
<#
Notes: 
This script adds the user assigned the personal desktop to the local Power Users group
#>
if($DesktopUser){
  if ((Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).domain -eq 'WORKGROUP') {
      Write-Output "No domain found. Assuming AzureAD joined."
      Add-LocalGroupMember -Group "Power Users" -Member "AzureAD\$DesktopUser"
  }
  else {
      Add-LocalGroupMember -Group "Power Users" -Member "$DesktopUser"
  }
}
else{
  Write-Error -Message 'ERROR: No Desktop User Specified. This VM may not be a personal Desktop.'
  exit
}
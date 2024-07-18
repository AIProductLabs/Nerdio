#description: Downloads and installs AWS VPN Client on the session hosts
#Written by Jason Sears
#No warranties given for this script
#execution mode: Combined
#tags: Nerdio, Apps install, AWS VPN Client
<# 
Notes:
This script installs AWS VPN Client on AVD Session hosts.

#>

$AwsVpnClientUrl = "https://d20adtppz83p9s.cloudfront.net/WPF/latest/AWS_VPN_Client.msi"

# Start powershell logging
$SaveVerbosePreference = $VerbosePreference
$VerbosePreference = 'continue'
$VMTime = Get-Date
$LogTime = $VMTime.ToUniversalTime()
mkdir "C:\Windows\temp\NerdioManagerLogs\ScriptedActions\awsvpnclient" -Force
Start-Transcript -Path "C:\Windows\temp\NerdioManagerLogs\ScriptedActions\awsvpnclient\ps_log.txt" -Append
Write-Host "################# New Script Run #################"
Write-host "Current time (UTC-0): $LogTime"

# Make directory to hold install files

mkdir "C:\Windows\Temp\awsvpnclient\install" -Force

Get-ChildItem C:\Windows\Temp\awsvpnclient\install\ | Remove-Item -Recurse -Force

Invoke-WebRequest -Uri $AwsVpnClientUrl -OutFile "C:\Windows\Temp\awsvpnclient\install\AWS_VPN_Client.msi" -UseBasicParsing


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
cd "C:\Windows\Temp\awsvpnclient\install\"


# Install AWS VPN Client. 
Write-Host "INFO: Installing AWS VPN Client. . ."
Start-Process "C:\Windows\Temp\awsvpnclient\install\AWS_VPN_Client.msi" -ArgumentList "ALLUSERS=1 /qn /norestart" -Wait -Passthru
  


Write-Host "INFO: AWS VPN Client install finished."

# End Logging
Stop-Transcript
$VerbosePreference=$SaveVerbosePreference

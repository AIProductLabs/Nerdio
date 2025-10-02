#description: Downloads and installs Azure VPN Client on the session hosts
#Written by Jason Sears
#No warranties given for this script
#execution mode: Combined
#tags: Nerdio, Apps install, Azure VPN Client
<# 
Notes:
This script downloads the Azure VPN Client package, extracts it, and runs the included Install.ps1 script.
The client will be installed but not configured - setup/configuration must be done separately.

#>

$AzureVpnClientUrl = "https://aka.ms/azvpnclientdownload"

# Start powershell logging
$SaveVerbosePreference = $VerbosePreference
$VerbosePreference = 'continue'
$VMTime = Get-Date
$LogTime = $VMTime.ToUniversalTime()
mkdir "C:\Windows\temp\NerdioManagerLogs\ScriptedActions\azurevpnclient" -Force
Start-Transcript -Path "C:\Windows\temp\NerdioManagerLogs\ScriptedActions\azurevpnclient\ps_log.txt" -Append
Write-Host "################# New Script Run #################"
Write-host "Current time (UTC-0): $LogTime"

# Make directory to hold install files
mkdir "C:\Windows\Temp\azurevpnclient\install" -Force
Get-ChildItem C:\Windows\Temp\azurevpnclient\install\ | Remove-Item -Recurse -Force

# Download Azure VPN Client installer package
Write-Host "INFO: Downloading Azure VPN Client from $AzureVpnClientUrl"
try {
    Invoke-WebRequest -Uri $AzureVpnClientUrl -OutFile "C:\Windows\Temp\azurevpnclient\install\AzureVpnClient.zip" -UseBasicParsing
    Write-Host "INFO: Azure VPN Client download completed successfully."
}
catch {
    Write-Error "ERROR: Failed to download Azure VPN Client: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Verify the downloaded file exists
if (-not (Test-Path "C:\Windows\Temp\azurevpnclient\install\AzureVpnClient.zip")) {
    Write-Error "ERROR: Downloaded installer package not found."
    Stop-Transcript
    exit 1
}

# Extract the downloaded zip file
Write-Host "INFO: Extracting Azure VPN Client package..."
try {
    Expand-Archive -Path "C:\Windows\Temp\azurevpnclient\install\AzureVpnClient.zip" -DestinationPath "C:\Windows\Temp\azurevpnclient\install\extracted" -Force
    Write-Host "INFO: Azure VPN Client package extracted successfully."
}
catch {
    Write-Error "ERROR: Failed to extract Azure VPN Client package: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}

# Find and execute the Install.ps1 script
$installScript = Get-ChildItem -Path "C:\Windows\Temp\azurevpnclient\install\extracted" -Filter "Install.ps1" | Select-Object -First 1
if (-not $installScript) {
    Write-Error "ERROR: Install.ps1 script not found in extracted package."
    Stop-Transcript
    exit 1
}

Write-Host "INFO: Found installer script: $($installScript.Name)"
Write-Host "INFO: Executing Azure VPN Client installation..."

try {
    # Change to the extracted directory and run Install.ps1 with Force parameter for silent install
    Set-Location -Path "C:\Windows\Temp\azurevpnclient\install\extracted"
    & ".\Install.ps1" -Force -SkipLoggingTelemetry
    Write-Host "INFO: Azure VPN Client installation script completed successfully."
}
catch {
    Write-Error "ERROR: Failed to execute installation script: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}

Write-Host "INFO: Azure VPN Client installation completed."
Write-Host "NOTE: The client has been installed but not configured. VPN profile setup must be done separately."

# Cleanup temporary files
Write-Host "INFO: Cleaning up temporary files..."
try {
    Set-Location -Path "C:\Windows\Temp"
    Remove-Item "C:\Windows\Temp\azurevpnclient\install" -Recurse -Force
    Write-Host "INFO: Temporary files cleaned up successfully."
}
catch {
    Write-Warning "WARNING: Failed to cleanup temporary files: $($_.Exception.Message)"
}

# End Logging
Stop-Transcript
$VerbosePreference = $SaveVerbosePreference
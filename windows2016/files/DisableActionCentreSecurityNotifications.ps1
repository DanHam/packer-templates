# Disable Security and Maintenance notifications in Action Centre
#
# This script stops Security and Maintenance notifications from appearing
# in Action Centre. This prevents notifications relating to actions
# performed in the build process from being displayed in the final image.
# Note that sysprep does not clear Action Centre notifications.

Write-Host 'Disabling Action Centre Security and Maintenance notifications'

$RegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\' +
          'Settings\Windows.SystemToast.SecurityAndMaintenance\'
$RegSetting = 'Enabled'

# Create the registry key if required
If ((Test-Path $RegKey) -ne $true) {
    New-Item -Path $RegKey -Force | Out-Null
}

# The setting will be automatically created if it doesn't exist
Set-ItemProperty -Path $RegKey -Name $RegSetting -Value '0' -Type DWORD -Force

Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
